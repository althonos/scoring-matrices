import pickle
import unittest
import sys

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

    def test_list(self):
        aa = ScoringMatrix.from_name("BLOSUM50")
        matrix = list(aa)
        columns = aa.alphabet
        self.assertEqual(len(columns), 24)
        self.assertEqual(len(matrix), 24)
        for row in matrix:
            self.assertEqual(len(row), 24)

    @unittest.skipUnless(sys.implementation.name == "cpython", "memoryview not supported")
    def test_memoryview(self):
        aa = ScoringMatrix.from_name("BLOSUM50")
        mem = memoryview(aa)
        self.assertEqual(mem.shape, (24, 24))
        self.assertEqual(mem[0, 0], 5.0) # A <-> A
        self.assertEqual(mem[6, 6], 6.0) # E <-> E
        
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