cimport cython
from cpython.memoryview cimport PyMemoryView_FromMemory
from cpython.buffer cimport PyBUF_FORMAT, PyBUF_READ, PyBUF_WRITE

from libc.math cimport INFINITY
from libc.stdlib cimport realloc, free
from libc.string cimport memcpy

import pickle
import struct

from .matrices cimport _NAMES, _ALPHABETS, _SIZES, _MATRICES

cdef dict _INDICES = {
    _NAMES[i].decode('ascii'):i
    for i in range(sizeof(_NAMES) /sizeof(const char*) - 1)
}

cdef class ScoringMatrix:
    """A scoring matrix to use for biological sequence alignments.
    """

    DEFAULT_ALPHABET = "ARNDCQEGHILKMFPSTWYVBZX*"
    BUILTIN_MATRICES = frozenset(_INDICES)

    @classmethod
    def builtin(cls, str name not None = "BLOSUM62"):
        """Load a built-in scoring matrix.

        Arguments:
            name (`str`): The name of the scoring matrix.

        Example:
            >>> blosum62 = ScoringMatrix.builtin("BLOSUM62")

        Raises:
            `ValueError`: When no scoring matrix with the given ``name``
                can be found in the embedded matrix data.

        """
        cdef size_t i
        cdef size_t j
        cdef size_t k
        cdef list   rows

        try:
            i = _INDICES[name]
        except KeyError as err:
            raise ValueError(f"Unknown scoring matrix: {name!r}") from err
        else:
            alphabet = _ALPHABETS[i].decode('ascii')

        rows = []
        for j in range(0, _SIZES[i] * _SIZES[i], _SIZES[i]):
            row = []
            for k in range(_SIZES[i]):
                row.append(_MATRICES[i][j + k])
            rows.append(row)

        return cls(rows, alphabet=alphabet, name=name)

    @classmethod
    def load(cls, object file):
        raise NotImplementedError

    @classmethod
    def loads(cls, str text):
        raise NotImplementedError

    def __cinit__(self):
        self._data = NULL
        self._matrix = NULL
        self._size = 0

    def __init__(
        self,
        object matrix not None,
        str alphabet not None = DEFAULT_ALPHABET,
        str name = None,
    ):
        """Create a new scoring matrix object.
        """
        cdef ssize_t i
        cdef ssize_t j
        cdef float   x
        cdef size_t  size = len(alphabet)

        if len(alphabet) != len(set(alphabet)):
            raise ValueError(f"Duplicate letters found in alphabet: {self.alphabet!r}")
        if len(matrix) != size:
            raise ValueError("Matrix must contain one row per alphabet letter")

        self.alphabet = alphabet
        self.name = name

        with nogil:
            self._allocate(size)

        assert self._data != NULL
        assert self._matrix != NULL
        for i, row in enumerate(matrix):
            if len(row) != size:
                raise ValueError("Matrix must contain one column per alphabet letter")
            for j, x in enumerate(row):
                self._matrix[i][j] = x

    def __copy__(self):
        return self.copy()

    def __repr__(self):
        cdef str ty    = type(self).__name__
        cdef list args = [repr(self.matrix)]

        if self.alphabet != ScoringMatrix.DEFAULT_ALPHABET:
            args.append(f"alphabet={self.alphabet!r}")
        if self.name is not None:
            args.append(f"name={self.name!r}")
        return f"{ty}({', '.join(args)})"

    def __reduce_ex__(self, int protocol):
        assert self._data != NULL
        assert self._matrix != NULL

        # use out-of-band pickling (only supported since protocol 5, see
        # https://docs.python.org/3/library/pickle.html#out-of-band-buffers)
        if protocol >= 5:
            matrix = pickle.PickleBuffer(self)
        else:
            matrix = self.matrix
        return (type(self), (matrix, self.alphabet, self.name))

    def __getbuffer__(self, Py_buffer* buffer, int flags):
        raise NotImplementedError

    def __len__(self):
        return self._size

    def __getitem__(self, object item):
        raise NotImplementedError

    def __eq__(self, object other):
        assert self._data != NULL
        assert self._matrix != NULL

        cdef size_t        i
        cdef size_t        j
        cdef ScoringMatrix other_

        if not isinstance(other, ScoringMatrix):
            return NotImplemented
        other_ = other
        if other_.alphabet != self.alphabet:
            return False
        for i in range(self._size):
            for j in range(self._size):
                if self.matrix[i][j] != other_.matrix[i][j]:
                    return False
        return True

    @property
    def matrix(self):
        """`list` of `list` of `float`: The score matrix.
        """
        assert self._data != NULL
        assert self._matrix != NULL
        return [
            [ self._matrix[i][j] for j in range(self._size) ]
            for i in range(self._size)
        ]

    cdef int _allocate(self, size_t size) except 1 nogil:
        cdef size_t i

        self._data = <float*> realloc(self._data, sizeof(float) * size * size)
        if self._data is NULL:
            raise MemoryError("Failed to allocate matrix")

        self._matrix = <float**> realloc(self._matrix, sizeof(float*) * size)
        if self._matrix is NULL:
            raise MemoryError("Failed to allocate matrix")

        self._size = size
        for i in range(size):
            self._matrix[i] = &self._data[i * self._size]

        return 0

    def dump(cls, object file):
        raise NotImplementedError

    def dumps(cls):
        raise NotImplementedError

    cpdef ScoringMatrix copy(self):
        cdef ScoringMatrix copy

        copy = ScoringMatrix.__new__(ScoringMatrix)
        copy.name = self.name
        copy.alphabet = self.alphabet
        with nogil:
            copy._allocate(self._size)
            memcpy(copy._data, self._data, self._size * self._size * sizeof(float))
        return copy

    cpdef float min(self):
        cdef size_t i
        cdef float  m = INFINITY

        with nogil:
            for i in range(self._size * self._size):
                if self._data[i] < m:
                    m = self._data[i]
        return m

    cpdef float max(self):
        cdef size_t i
        cdef float  m = -INFINITY

        with nogil:
            for i in range(self._size * self._size):
                if self._data[i] > m:
                    m = self._data[i]
        return m