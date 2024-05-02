cimport cython
from cpython.memoryview cimport PyMemoryView_FromMemory
from cpython.buffer cimport PyBUF_FORMAT, PyBUF_READ, PyBUF_WRITE

from libc.math cimport INFINITY, roundf
from libc.stdlib cimport realloc, free
from libc.string cimport memcpy

from .matrices cimport _NAMES, _ALPHABETS, _SIZES, _MATRICES

import io
import pickle


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
    def load(cls, object file, str name = None):
        # ignore lines with comments
        lines = filter(lambda line: not line.startswith("#"), file)

        # get the header line with the alphabet
        header = next(lines, None)
        if header is None:
            raise ValueError("Missing expected header line")
        alphabet = ''.join(header.split())

        # get the numerical matrix
        matrix = []
        for i, line in enumerate(lines):
            row = line.split()
            try:
                float(row[0])
            except ValueError:
                if row[0] != alphabet[i]:
                    raise ValueError(f"Matrix must be symmetric (expected row {alphabet[i]!r}, got {row[0]!r})") from None
                row = row[1:]
            matrix.append(list(map(float, row)))

        # create the object with default constructor
        return cls(matrix, alphabet=alphabet, name=name)

    @classmethod
    def loads(cls, str text, str name = None):
        return cls.load(io.StringIO(text))

    def __cinit__(self):
        self._data = NULL
        self._matrix = NULL
        self._size = 0
        self._shape[0] = self._shape[1] = 0

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
        assert self._data != NULL

        if flags & PyBUF_FORMAT:
            buffer.format = b"f"
        else:
            buffer.format = NULL
        buffer.buf = self._data
        buffer.internal = NULL
        buffer.itemsize = sizeof(float)
        buffer.len = self._nitems * sizeof(float)
        buffer.ndim = 2
        buffer.obj = self
        buffer.readonly = 1
        buffer.shape = <Py_ssize_t*> &self._shape
        buffer.suboffsets = NULL
        buffer.strides = NULL

    def __len__(self):
        return self._size

    def __getitem__(self, object item):
        cdef ssize_t index_
        cdef list    row

        if isinstance(item, str) and len(item) == 1:
            try:
                item = self.alphabet.index(item)
            except ValueError:
                raise IndexError(f"{item!r} not in matrix alphabet ({self.alphabet!r})") from None

        if isinstance(item, int):
            index_ = item
            if index_ < 0:
                index_ += self._size
            if index_ < 0 or index_ >= self._size:
                raise IndexError(item)
            row = []
            for i in range(self._size):
                row.append(self._matrix[index_][i])
            return row

        elif isinstance(item, tuple):
            if len(item) > 2:
                raise IndexError(f"too many indices for array: array is 2-dimensional, but {len(item)!r} were indexed")
            i, j = item
            if isinstance(i, str) and len(i) == 1:
                try:
                    i = self.alphabet.index(i)
                except ValueError:
                    raise IndexError(f"{i!r} not in matrix alphabet ({self.alphabet!r})") from None
            if isinstance(j, str) and len(j) == 1:
                try:
                    j = self.alphabet.index(j)
                except ValueError:
                    raise IndexError(f"{j!r} not in matrix alphabet ({self.alphabet!r})") from None
            if isinstance(i, int) and isinstance(j, int):
                return self._matrix[i][j]

        raise TypeError(item)

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

    cdef int _allocate(self, size_t size) except 1 nogil:
        cdef size_t i

        self._data = <float*> realloc(self._data, sizeof(float) * size * size)
        if self._data is NULL:
            raise MemoryError("Failed to allocate matrix")

        self._matrix = <float**> realloc(self._matrix, sizeof(float*) * size)
        if self._matrix is NULL:
            raise MemoryError("Failed to allocate matrix")

        self._size = self._shape[0] = self._shape[1] = size
        self._nitems = self._size * self._size
        for i in range(size):
            self._matrix[i] = &self._data[i * self._size]

        return 0

    def dump(cls, object file):
        raise NotImplementedError

    def dumps(cls):
        raise NotImplementedError

    cpdef ScoringMatrix copy(self):
        return type(self)( self, alphabet=self.alphabet, name=self.name)

    cpdef bint is_integer(self):
        """Test whether the scoring matrix is an integer matrix.

        Example:
            >>> blosum62 = ScoringMatrix.builtin("BLOSUM62")
            >>> blosum62.is_integer()
            True
            >>> benner6 = ScoringMatrix.builtin("BENNER6")
            >>> benner6.is_integer()
            False

        """
        assert self._data != NULL

        cdef size_t i
        cdef float  x
        cdef bint   integer = True

        with nogil:
            for i in range(self._nitems):
                x = self._data[i]
                if roundf(x) != x:
                    integer = False
                    break
        return integer

    cpdef float min(self):
        assert self._data != NULL

        cdef size_t i
        cdef float  m = INFINITY

        with nogil:
            for i in range(self._nitems):
                if self._data[i] < m:
                    m = self._data[i]
        return m

    cpdef float max(self):
        assert self._data != NULL
        
        cdef size_t i
        cdef float  m = -INFINITY

        with nogil:
            for i in range(self._nitems):
                if self._data[i] > m:
                    m = self._data[i]
        return m