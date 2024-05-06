import configparser
import functools
import ftplib
import glob
import itertools
import io
import json
import multiprocessing.pool
import os
import platform
import re
import setuptools
import setuptools.extension
import subprocess
import string
import sys
import sysconfig
from distutils.command.clean import clean as _clean
from distutils.errors import CompileError
from setuptools.command.build_ext import build_ext as _build_ext
from setuptools.command.sdist import sdist as _sdist
from setuptools.extension import Extension

try:
    from Cython.Build import cythonize
except ImportError as err:
    cythonize = err


# --- Utils ------------------------------------------------------------------

def _eprint(*args, **kwargs):
    print(*args, **kwargs, file=sys.stderr)


def _split_multiline(value):
    value = value.strip()
    sep = max('\n,;', key=value.count)
    return list(filter(None, map(lambda x: x.strip(), value.split(sep))))


# --- Commands ------------------------------------------------------------------


class sdist(_sdist):
    """A `sdist` that generates a `pyproject.toml` on the fly."""

    def run(self):
        # generate score matrices
        if not self.distribution.have_run.get("build_matrices", False):
            _build_cmd = self.get_finalized_command("build_matrices")
            _build_cmd.force = self.force
            _build_cmd.run()
        # build `pyproject.toml` from `setup.cfg`
        c = configparser.ConfigParser()
        c.add_section("build-system")
        c.set("build-system", "requires", str(self.distribution.setup_requires))
        c.set("build-system", "build-backend", '"setuptools.build_meta"')
        with open("pyproject.toml", "w") as pyproject:
            c.write(pyproject)
        # run the rest of the packaging
        _sdist.run(self)


class build_matrices(setuptools.Command):

    user_options = [
        ('force', 'f', 'force generation of files'),
        ('output=', 'o', 'output file to write'),
        ('matrices=', 'm', 'matrices to generate'),
    ]

    def initialize_options(self) -> None:
        self.force = False
        self.output = None
        self.matrices = None

    def finalize_options(self) -> None:
        self.folder = "data"
        self.output = os.path.join("scoring_matrices", "matrices.h")
        if self.matrices is not None:
            self.matrices = _split_multiline(self.matrices)
        else:
            self.matrices = [
                os.path.splitext(os.path.basename(mat))[0]
                for mat in glob.glob(os.path.join(self.folder, "*.mat"))
            ]

    def run(self):
        matrix_files = [ os.path.join(self.folder, f"{matrix}.mat") for matrix in self.matrices ]
        self.make_file(matrix_files, self.output, self._generate_matrices, (matrix_files, self.output))

    def _parse_matrix_file(self, matrix_file):
        with open(matrix_file) as f:
            lines = filter(
                lambda line: line and not line.startswith("#"),
                map(str.strip, f),
            )
            letters = ''.join(next(lines).split())
            matrix = [
                list(map(float, line.strip().split()[1:]))
                for line in map(str.strip, lines)
                if line
            ]
        return letters, matrix

    def _generate_matrices(self, matrix_files, output_file):
        matrices = {}
        for matrix_file in matrix_files:
            matrix_name = os.path.splitext(os.path.basename(matrix_file))[0].upper()
            matrices[matrix_name] = self._parse_matrix_file(matrix_file)

        with open(output_file, "w") as dst:
            dst.write("#include <stddef.h>\n")
            names = sorted(matrices.keys())
            ids = [ name.replace(".", "_") for name in names ]
           
            dst.write(f"const char* _NAMES[{len(names) + 1}] = {{")
            for name in names:
                dst.write(f'"{name}", ')
            dst.write("NULL };\n")

            dst.write(f"const char* _ALPHABETS[{len(names) + 1}] = {{")
            for name in names:
                alphabet, _ = matrices[name]
                dst.write(f'"{alphabet}", ')
            dst.write("NULL };\n")

            dst.write(f"const size_t _SIZES[{len(names) + 1}] = {{")
            for name in names:
                alphabet, _ = matrices[name]
                dst.write(f'{len(alphabet)}, ')
            dst.write("-1 };\n")

            for i, (name, id_) in enumerate(zip(names, ids)):
                alphabet, matrix = matrices[name]
                nitems = len(matrix) * len(matrix)
                dst.write(f"float _MATRIX_{id_}[{nitems}] = {{")
                for i, item in enumerate(itertools.chain.from_iterable(matrix)):
                    if i != 0:
                        dst.write(", ")
                    dst.write(f"{item!r}F")
                dst.write("};\n")

            dst.write(f"const float* _MATRICES[{len(names) + 1}] = {{")
            for id_ in ids:
                dst.write(f'_MATRIX_{id_}, ')
            dst.write("NULL };\n")


class build_ext(_build_ext):
    """A `build_ext` that adds various SIMD flags and defines."""

    # --- Compatibility with `setuptools.Command`

    def initialize_options(self):
        _build_ext.initialize_options(self)

    def finalize_options(self):
        _build_ext.finalize_options(self)
        # check platform
        if self.plat_name is None:
            self.plat_name = sysconfig.get_platform()

    # --- Autotools-like helpers ---

    def _check_getid(self):
        _eprint('checking whether `PyInterpreterState_GetID` is available')

        base = "have_getid"
        testfile = os.path.join(self.build_temp, "{}.c".format(base))
        objects = []

        self.mkpath(self.build_temp)
        with open(testfile, "w") as f:
            f.write("""
            #include <stdint.h>
            #include <stdlib.h>
            #include <Python.h>

            int main(int argc, char *argv[]) {{
                PyInterpreterState_GetID(NULL);
                return 0;
            }}
            """)

        if self.compiler.compiler_type == "msvc":
            flags = ["/WX"]
        else:
            flags = ["-Werror=implicit-function-declaration"]

        try:
            self.mkpath(self.build_temp)
            objects = self.compiler.compile([testfile], extra_postargs=flags)
        except CompileError:
            _eprint("no")
            return False
        else:
            _eprint("yes")
            return True
        finally:
            os.remove(testfile)
            for obj in filter(os.path.isfile, objects):
                os.remove(obj)

    # --- Build code ---

    def build_extension(self, ext):
        # show the compiler being used
        _eprint("building", ext.name, "with", self.compiler.compiler_type, "compiler for platform", self.plat_name)

        # add debug symbols if we are building in debug mode
        if self.debug:
            if self.compiler.compiler_type in {"unix", "cygwin", "mingw32"}:
                ext.extra_compile_args.append("-g")
            elif self.compiler.compiler_type == "msvc":
                ext.extra_compile_args.append("/Z7")
            if sys.implementation.name == "cpython":
                ext.define_macros.append(("CYTHON_TRACE_NOGIL", 1))
        else:
            ext.define_macros.append(("CYTHON_WITHOUT_ASSERTIONS", 1))

        # add Windows flags
        if self.compiler.compiler_type == "msvc":
            ext.define_macros.append(("WIN32", 1))

        # build the rest of the extension as normal
        ext._needs_stub = False

        # compile extension in its own folder: since we need to compile
        # `tantan.cc` several times with different flags, we cannot use the
        # default build folder, otherwise the built object would be cached
        # and prevent recompilation
        _build_temp = self.build_temp
        self.build_temp = os.path.join(_build_temp, ext.name)
        _build_ext.build_extension(self, ext)
        self.build_temp = _build_temp

    def build_extensions(self):
        # check `cythonize` is available
        if isinstance(cythonize, ImportError):
            raise RuntimeError(
                "Cython is required to run `build_ext` command"
            ) from cythonize

        # generate score matrices
        if not self.distribution.have_run.get("build_matrices", False):
            _build_cmd = self.get_finalized_command("build_matrices")
            _build_cmd.force = self.force
            _build_cmd.run()

        # use debug directives with Cython if building in debug mode
        cython_args = {
            "include_path": ["include"],
            "compiler_directives": {
                "cdivision": True,
                "nonecheck": False,
            },
            "compile_time_env": {
                "SYS_IMPLEMENTATION_NAME": sys.implementation.name,
                "SYS_VERSION_INFO_MAJOR": sys.version_info.major,
                "SYS_VERSION_INFO_MINOR": sys.version_info.minor,
                "SYS_VERSION_INFO_MICRO": sys.version_info.micro,
                "DEFAULT_BUFFER_SIZE": io.DEFAULT_BUFFER_SIZE,
            },
        }
        if self.force:
            cython_args["force"] = True
        if self.debug:
            cython_args["annotate"] = True
            cython_args["compiler_directives"]["cdivision_warnings"] = True
            cython_args["compiler_directives"]["warn.undeclared"] = True
            cython_args["compiler_directives"]["warn.unreachable"] = True
            cython_args["compiler_directives"]["warn.maybe_uninitialized"] = True
            cython_args["compiler_directives"]["warn.unused"] = True
            cython_args["compiler_directives"]["warn.unused_arg"] = True
            cython_args["compiler_directives"]["warn.unused_result"] = True
            cython_args["compiler_directives"]["warn.multiple_declarators"] = True
        else:
            cython_args["compiler_directives"]["boundscheck"] = False
            cython_args["compiler_directives"]["wraparound"] = False

        # check if `PyInterpreterState_GetID` is defined
        if self._check_getid():
            self.compiler.define_macro("HAS_PYINTERPRETERSTATE_GETID", 1)

        # cythonize the extensions
        self.extensions = cythonize(self.extensions, **cython_args)

        # build the extensions as normal
        _build_ext.build_extensions(self)


class clean(_clean):
    """A `clean` that removes intermediate files created by Cython."""

    def run(self):

        source_dir = os.path.join(os.path.dirname(__file__), "pytantan")

        patterns = ["*.html"]
        if self.all:
            patterns.extend(["*.so", "*.c", "*.cpp"])

        for pattern in patterns:
            for file in glob.glob(os.path.join(source_dir, pattern)):
                _eprint("removing {!r}".format(file))
                os.remove(file)

        for ext in self.distribution.ext_modules:
            for source_file in ext.sources:
                if source_file.endswith(".pyx"):
                    ext = ".cpp" if ext.language == "c++" else ".c"
                    c_file = source_file.replace(".pyx", ext)
                    if os.path.exists(c_file):
                        _eprint("removing {!r}".format(c_file))
                        os.remove(c_file)

        _clean.run(self)


# --- Setup ---------------------------------------------------------------------

setuptools.setup(
    ext_modules=[
        Extension(
            "scoring_matrices.lib",
            language="c",
            include_dirs=["scoring_matrices"],
            sources=[os.path.join("scoring_matrices", "lib.pyx")],
        ),
    ],
    cmdclass={
        "sdist": sdist,
        "build_ext": build_ext,
        "build_matrices": build_matrices,
        "clean": clean,
    },
)
