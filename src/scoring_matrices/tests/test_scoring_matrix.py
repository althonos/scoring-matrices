import pickle
import sys
import unittest

from scoring_matrices import ScoringMatrix


class TestScoringMatrix(unittest.TestCase):

    def test_from_name_blosum50(self):
        matrix = ScoringMatrix.from_name("BLOSUM50")
        diagonal = [ matrix[i, i] for i in range(len(matrix)) ]
        self.assertEqual(len(diagonal), 24)
        self.assertEqual(diagonal, [5, 7, 7, 8, 13, 7, 6, 8, 10, 5, 5, 6, 7, 8, 10, 5, 5, 15, 8, 5, 5, 5 ,-1 ,1])

    def test_from_name_blosum62(self):
        matrix = ScoringMatrix.from_name("BLOSUM62")
        diagonal = [ matrix[i, i] for i in range(len(matrix)) ]
        self.assertEqual(len(diagonal), 24)
        self.assertEqual(diagonal, [4, 5, 6, 6, 9, 5, 5, 6, 8, 4, 4, 5, 5, 6, 7, 4, 5, 11, 7, 4, 4, 4, -1, 1])

    def test_from_name_invalid_name(self):
        with self.assertRaises(ValueError):
            aa = ScoringMatrix.from_name("nonsensical")

    def test_from_str(self):
        m1 = ScoringMatrix.from_str(
            """
                A   T   G   C
            A   5  -4  -4  -4
            T  -4   5  -4  -4
            G  -4  -4   5  -4
            C  -4  -4  -4   5
            """.strip()
        )
        self.assertEqual(m1.alphabet, "ATGC")
        self.assertEqual(m1['T', 'A'], -4.0)
        self.assertEqual(m1['A', 'A'], 5.0)

        m2 = ScoringMatrix.from_str(
            """
             A   T   G   C
             5  -4  -4  -4
            -4   5  -4  -4
            -4  -4   5  -4
            -4  -4  -4   5
            """.strip()
        )
        self.assertEqual(m2.alphabet, "ATGC")
        self.assertEqual(m2['T', 'A'], -4.0)
        self.assertEqual(m2['A', 'A'], 5.0)

    def test_from_diagonal(self):
        m = ScoringMatrix.from_diagonal([1, 2, 3, 4], 0.0, alphabet="ATGC")
        self.assertEqual(m[0], [1.0, 0.0, 0.0, 0.0])
        self.assertEqual(m[1], [0.0, 2.0, 0.0, 0.0])
        self.assertEqual(m[2], [0.0, 0.0, 3.0, 0.0])
        self.assertEqual(m[3], [0.0, 0.0, 0.0, 4.0])

        m = ScoringMatrix.from_diagonal([1, 2, 3, 4], -1.0, alphabet="ATGC")
        self.assertEqual(m[0], [ 1.0, -1.0, -1.0, -1.0])
        self.assertEqual(m[1], [-1.0,  2.0, -1.0, -1.0])
        self.assertEqual(m[2], [-1.0, -1.0,  3.0, -1.0])
        self.assertEqual(m[3], [-1.0, -1.0, -1.0,  4.0])

    def test_from_diagonal_invalid_length(self):
        self.assertRaises(
            ValueError,
            ScoringMatrix.from_diagonal,
            [ 3, 3, 3, 3, 3, 3 ],
            alphabet="ATGC"
        )
        self.assertRaises(
            ValueError,
            ScoringMatrix.from_diagonal,
            [ 3, 3, 3 ],
            alphabet="ATGC"
        )

    def test_list(self):
        aa = ScoringMatrix.from_name("BLOSUM50")
        matrix = list(aa)
        columns = aa.alphabet
        self.assertEqual(len(columns), 24)
        self.assertEqual(len(matrix), 24)
        for row in matrix:
            self.assertEqual(len(row), 24)

    @unittest.skipUnless(sys.implementation.name == "cpython", "memoryview not supported")
    @unittest.skipUnless(sys.version_info >= (3, 9), "memoryview not supported")
    def test_memoryview(self):
        aa = ScoringMatrix.from_name("BLOSUM50")
        # mem = memoryview(aa)
        mem = aa.buffer
        self.assertEqual(mem.shape, (24, 24))
        self.assertEqual(mem[0, 0], 5.0) # A <-> A
        self.assertEqual(mem[6, 6], 6.0) # E <-> E

    def test_init_empty(self):
        m = ScoringMatrix([], alphabet="")
        self.assertEqual(len(m), 0)
        self.assertFalse(bool(m))

    def test_init_invalid_length(self):
        with self.assertRaises(ValueError):
            m = ScoringMatrix(
                [
                    [0, 0, 0, 0],
                    [0, 0, 0, 0],
                    [0, 0, 0, 0],
                ],
                alphabet="ATGC",
            )
        with self.assertRaises(ValueError):
            m = ScoringMatrix(
                [
                    [0, 0, 0, 0],
                    [0, 0, 0, 0],
                    [0, 0, 0, 0],
                    [0, 0, 0],
                ],
                alphabet="ATGC",
            )

    def test_eq(self):
        sm1 = ScoringMatrix.from_name("BLOSUM50")
        sm2 = ScoringMatrix.from_name("BLOSUM50")
        sm3 = ScoringMatrix.from_name("BLOSUM62")
        self.assertEqual(sm1, sm1)
        self.assertEqual(sm1, sm2)
        self.assertNotEqual(sm1, sm3)
        self.assertNotEqual(sm1, 12)

    def test_pickle(self):
        sm1 = ScoringMatrix.from_name("BLOSUM62")
        sm2 = pickle.loads(pickle.dumps(sm1))
        self.assertEqual(sm1.alphabet, sm2.alphabet)
        self.assertEqual(list(sm1), list(sm2))

    def test_shuffle_invalid_alphabet(self):
        matrix = ScoringMatrix.from_name("BLOSUM62")
        self.assertRaises(KeyError, matrix.shuffle, "ARNJOU")

    def test_shuffle_empty(self):
        matrix = ScoringMatrix.from_name("BLOSUM62")
        empty = matrix.shuffle("")
        self.assertEqual(len(empty), 0)
        self.assertFalse(bool(empty))

    def test_is_symmetric(self):
        matrix = ScoringMatrix.from_name("PAM250")
        self.assertTrue(matrix.is_symmetric())
        matrix = ScoringMatrix([[1, 2, 3], [4, 5, 6], [7, 8, 9]], "ABC")
        self.assertFalse(matrix.is_symmetric())