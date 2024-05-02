# coding: utf-8
"""Test doctest contained tests in every file of the module.
"""

import configparser
import doctest
import importlib
import os
import pkgutil
import re
import shutil
import sys
import types
import warnings
from unittest import mock

import scoring_matrices


def _load_tests_from_module(tests, module, globs, setUp=None, tearDown=None):
    """Load tests from module, iterating through submodules."""
    for attr in (getattr(module, x) for x in dir(module) if not x.startswith("_")):
        if isinstance(attr, types.ModuleType):
            suite = doctest.DocTestSuite(
                attr,
                globs,
                setUp=setUp,
                tearDown=tearDown,
                optionflags=+doctest.ELLIPSIS,
            )
            tests.addTests(suite)
    return tests


def load_tests(loader, tests, ignore):
    """`load_test` function used by unittest to find the doctests."""
    _current_cwd = os.getcwd()
    # demonstrate how to use Biopython substitution matrices without
    # actually requiring Biopython
    Bio = mock.Mock()
    Bio.Align = mock.Mock()
    Bio.Align.substitution_matrices = mock.Mock()
    Bio.Align.substitution_matrices.load = mock.Mock()
    Bio.Align.substitution_matrices.load.return_value = feng = mock.Mock()

    data = [ [-1 for _ in range(20)] for _ in range(20) ]
    for i in range(20):
        data[i][i] = 1

    feng.alphabet = "ARNDCQEGHILKMFPSTWYV"
    feng.__len__ = mock.Mock(return_value=20)
    feng.__iter__ = mock.Mock(wraps=data.__iter__)

    def setUp(self):
        warnings.simplefilter("ignore")
        # os.chdir(os.path.realpath(os.path.join(__file__, os.path.pardir, "data")))

    def tearDown(self):
        # os.chdir(_current_cwd)
        warnings.simplefilter(warnings.defaultaction)

    # doctests are not compatible with `green`, so we may want to bail out
    # early if `green` is running the tests
    if sys.argv[0].endswith("green"):
        return tests

    # recursively traverse all library submodules and load tests from them
    packages = [None, scoring_matrices.lib]

    for pkg in iter(packages.pop, None):
        globs = dict(scoring_matrices=scoring_matrices, Bio=Bio, **pkg.__dict__)
        tests.addTests(
            doctest.DocTestSuite(
                pkg,
                globs=globs,
                setUp=setUp,
                tearDown=tearDown,
                optionflags=+doctest.ELLIPSIS,
            )
        )

    return tests
