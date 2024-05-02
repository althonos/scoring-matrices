# noqa: D104

from . import (
    test_doctest,
    test_scoring_matrix,
)


def load_tests(loader, suite, pattern):
    test_doctest.load_tests(loader, suite, pattern)
    suite.addTests(loader.loadTestsFromModule(test_scoring_matrix))
    return suite
