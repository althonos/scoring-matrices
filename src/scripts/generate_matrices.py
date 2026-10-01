import argparse
import itertools
import math
import os


def _c_float_literal(value):
    if math.isinf(value):
        return "INFINITY" if value > 0.0 else "-INFINITY"
    return f"{value!r}F"


def _parse_matrix_file(matrix_file):
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

def _generate_matrices(matrix_files, output_file):
    matrices = {}
    for matrix_file in matrix_files:
        matrix_name = os.path.splitext(os.path.basename(matrix_file))[0].upper()
        matrices[matrix_name] = _parse_matrix_file(matrix_file)

    with open(output_file, "w") as dst:
        dst.write("#include <stddef.h>\n")
        dst.write("#include <math.h>\n")
        names = sorted(matrices.keys())
        ids = [ name.replace(".", "_") for name in names ]
        
        dst.write(f"const char* _NAMES[{len(names) + 1}] = {{")
        dst.writelines(f'"{name}", ' for name in names)
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
                dst.write(_c_float_literal(item))
            dst.write("};\n")

        dst.write(f"const float* _MATRICES[{len(names) + 1}] = {{")
        for id_ in ids:
            dst.write(f'_MATRIX_{id_}, ')
        dst.write("NULL };\n")


parser = argparse.ArgumentParser()
parser.add_argument("--output", required=True)
parser.add_argument("inputs", nargs="+")
args = parser.parse_args()

_generate_matrices(args.inputs, args.output)
