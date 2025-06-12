# distutils: language = c
# cython: language_level=3, linetrace=True, binding=True
"""Dependency free, Cython-compatible scoring matrices for bioinformatics.
"""

cimport cython
from cpython.buffer cimport PyBUF_FORMAT, PyBUF_READ, PyBUF_WRITE
from cpython.memoryview cimport PyMemoryView_FromMemory

from libc.math cimport INFINITY, lrintf
from libc.stdlib cimport free, realloc
from libc.string cimport memcpy, memset

from .matrices cimport _ALPHABETS, _MATRICES, _NAMES, _SIZES

import io
import pickle

__version__ = PROJECT_VERSION

cdef dict _INDICES = {
    _NAMES[i].decode('ascii'):i
    for i in range(sizeof(_NAMES) /sizeof(const char*) - 1)
}

cdef class ScoringMatrix:
    """A scoring matrix to use for biological sequence alignments.
    """

    DEFAULT_ALPHABET = "ARNDCQEGHILKMFPSTWYVBZX*"
    BUILTIN_MATRICES = frozenset(_INDICES)

    # --- Constructors ---------------------------------------------------------

    @classmethod
    def from_name(cls, str name not None = "BLOSUM62"):
        """Load a built-in scoring matrix by name.

        Arguments:
            name (`str`): The name of the scoring matrix.

        Example:
            >>> blosum62 = ScoringMatrix.from_name("BLOSUM62")

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
    def from_file(cls, object file, str name = None):
        """Load a scoring matrix from a file-like object.
        """
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
    def from_str(cls, str text, str name = None):
        """Load a scoring matrix from a string.
        """
        return cls.from_file(io.StringIO(text))

    @classmethod
    def from_diagonal(
        cls, 
        object diagonal, 
        float mismatch_score=0.0, 
        str alphabet not None = DEFAULT_ALPHABET, 
        str name = None
    ):
        """Create a scoring matrix from a diagonal vector.

        Arguments:
            diagonal (sequence of `float`): The diagonal of the scoring
                matrix, used to score character matches.
            mismatch_score (`float`): The mismatch score to use for 
                every mismatches.
            alphabet (`str`): The alphabet to use with the scoring matrix.
            name (`str` or `None`): A name for the scoring matrix, if any.

        Example:
            >>> matrix = ScoringMatrix.from_diagonal(
            ...     diagonal=[2, 2, 3, 3],
            ...     mismatch_score=-3.0,
            ...     alphabet="ATGC",
            ... )
            >>> for row in matrix:
            ...     print(row)
            [2.0, -3.0, -3.0, -3.0]
            [-3.0, 2.0, -3.0, -3.0]
            [-3.0, -3.0, 3.0, -3.0]
            [-3.0, -3.0, -3.0, 3.0]

        .. versionadded:: 0.2.0

        """
        cdef list   matrix = []
        cdef size_t length = len(alphabet)

        for i, x in enumerate(diagonal):
            row = [ x if j == i else mismatch_score for j in range(length) ]
            matrix.append(row)
        return cls(matrix, alphabet=alphabet, name=name)

    @classmethod
    def from_match_mismatch(
        cls,
        float match_score = 1.0, 
        float mismatch_score = -1.0,
        str alphabet not None = DEFAULT_ALPHABET,
        str name = None,
    ):
        """Create a scoring matrix from two match/mismatch scores.

        .. versionadded:: 0.2.0

        """
        cdef list   matrix = []
        cdef size_t length = len(alphabet)

        for i in range(length):
            row = [ match_score if j == i else mismatch_score for j in range(length) ]
            matrix.append(row)
        return cls(matrix, alphabet=alphabet, name=name)

    # --- Magic methods --------------------------------------------------------

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
        """__init__(self, matrix, alphabet="ARNDCQEGHILKMFPSTWYVBZX", name=None)\n--\n
        
        Create a new scoring matrix.

        Arguments:
            matrix (array-like of `float`): A square matrix with dimensions
                equal to the ``alphabet`` length, storing the scores for each
                pair of characters.
            alphabet (`str`): The alphabet used to index the rows and columns
                of the scoring matrix.
            name (`str` or `None`): The name of the scoring matrix, if any.

        Example:
            >>> matrix = ScoringMatrix(
            ...     [[91, -114,  -31, -123],
            ...      [-114, 100, -125, -31],
            ...      [-31, -125,  100, -114],
            ...      [-123, -31, -114,  91]],
            ...     alphabet="ACGT",
            ...     name="HOXD70",
            ... )

        Raises:
            `ValueError`: When the matrix is not a valid matrix or does not
                match the given alphabet.
            `MemoryError`: When memory for storing the scores could not be
                allocated successfully.

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

        for i, c in enumerate(self.alphabet):
            self._alphabet[i] = ord(c)
        for i, row in enumerate(matrix):
            if len(row) != size:
                raise ValueError("Matrix must contain one column per alphabet letter")
            for j, x in enumerate(row):
                self._matrix[i][j] = x

    def __copy__(self):
        return self.copy()

    def __repr__(self):
        cdef str ty    = type(self).__name__
        cdef list args = [repr(list(self))]

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
            matrix = list(self)
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
        cdef ScoringMatrix other_

        if not isinstance(other, ScoringMatrix):
            return NotImplemented
        other_ = other
        if other_.alphabet != self.alphabet:
            return False
        for i in range(self._nitems):
            if self._data[i] != other_._data[i]:
                return False
        return True

    # --- Private methods ------------------------------------------------------
    
    cdef int _allocate(self, size_t size) except 1 nogil:
        cdef size_t i

        self._data = <float*> realloc(self._data, sizeof(float) * size * size)
        self._matrix = <float**> realloc(self._matrix, sizeof(float*) * size)
        self._alphabet = <char*> realloc(self._alphabet, sizeof(char) * (size + 1))
        if self._data is NULL or self._matrix is NULL or self._alphabet is NULL:
            raise MemoryError("Failed to allocate matrix")

        self._size = self._shape[0] = self._shape[1] = size
        self._nitems = self._size * self._size
        for i in range(size):
            self._matrix[i] = &self._data[i * self._size]
        memset(self._alphabet, 0, sizeof(char) * (size + 1))

        return 0

    # --- Public methods -------------------------------------------------------

    cdef size_t size(self) noexcept nogil:
        """Get the size of the scoring matrix.
        """
        return self._size

    cdef const char* alphabet_ptr(self) except NULL nogil:
        """Get the alphabet of the scoring matrix as a C-string.
        """
        if self._alphabet == NULL:
            with gil:
                raise RuntimeError("uninitialized scoring matrix")
        return <const char*> self._alphabet

    cdef const float* data_ptr(self) except NULL nogil:
        """Get the matrix scores as a dense array.
        """
        if self._data == NULL:
            with gil:
                raise RuntimeError("uninitialized scoring matrix")
        return <const float*> self._data

    cdef const float** matrix_ptr(self) except NULL nogil:
        """Get the matrix scores as an array of pointers.
        """
        if self._matrix == NULL:
            with gil:
                raise RuntimeError("uninitialized scoring matrix")
        return <const float**> self._matrix

    cpdef ScoringMatrix copy(self):
        """Get a copy of the matrix.
        """
        return type(self)(self, alphabet=self.alphabet, name=self.name)

    cpdef bint is_integer(self):
        """Test whether the scoring matrix is an integer matrix.

        Returns:
            `bool`: `True` if the matrix only contains integer scores.

        Example:
            >>> blosum62 = ScoringMatrix.from_name("BLOSUM62")
            >>> blosum62.is_integer()
            True
            >>> benner6 = ScoringMatrix.from_name("BENNER6")
            >>> benner6.is_integer()
            False

        """
        cdef size_t       i
        cdef float        x
        cdef bint         integer = True
        cdef const float* _data   = self.data_ptr()

        with nogil:
            for i in range(self._nitems):
                x = _data[i]
                if lrintf(x) != x:
                    integer = False
                    break
        return integer

    cpdef bint is_symmetric(self):
        """Test whether the scoring matrix is symmetric.

        Returns:
            `bool`: `True` if the matrix is a symmetric matrix.

        .. versionadded:: 0.2.0

        """
        cdef size_t        i
        cdef size_t        j
        cdef bint          symmetric = True
        cdef const float** _matrix   = self.matrix_ptr()

        with nogil:
            for i in range(self._size):
                for j in range(i + 1, self._size):
                    if _matrix[i][j] != _matrix[j][i]:
                        symmetric = False
                        break
        return symmetric

    cpdef float min(self):
        """Get the minimum score of the scoring matrix.

        Example:
            >>> blosum62 = ScoringMatrix.from_name("BLOSUM62")
            >>> blosum62.min()
            -4.0

        """
        assert self._data != NULL

        cdef size_t i
        cdef float  m = INFINITY

        with nogil:
            for i in range(self._nitems):
                if self._data[i] < m:
                    m = self._data[i]
        return m

    cpdef float max(self):
        """Get the maximum score of the scoring matrix.

        Example:
            >>> blosum62 = ScoringMatrix.from_name("BLOSUM62")
            >>> blosum62.max()
            11.0

        """
        assert self._data != NULL
        
        cdef size_t i
        cdef float  m = -INFINITY

        with nogil:
            for i in range(self._nitems):
                if self._data[i] > m:
                    m = self._data[i]
        return m

    cpdef ScoringMatrix shuffle(self, str alphabet):
        """Shuffle the matrix using the new given alphabet.

        The matrix name is retained only when the provided ``alphabet`` is a
        permutation of the current alphabet, e.g. there is no loss of data.

        Arguments:
            alphabet (`str`): The new alphabet to use for the columns. It 
                must be a subset of ``self.alphabet``.

        Raises:
            `KeyError`: When some required alphabet letters are missing from
                the source matrix alphabet.

        Example:
            >>> m1 = ScoringMatrix.from_name("BLOSUM62")
            >>> m1[1, 1]
            5.0
            >>> m1['R', 'R']
            5.0
            >>> m2 = m1.shuffle("ABCDEFGHIKLMNPQRSTVWXYZ*")
            >>> m2[1, 1]
            4.0
            >>> m2['R', 'R']
            5.0

        """
        cdef size_t i
        cdef list   indices = []
        cdef list   matrix  = []

        for x in alphabet:
            try:
                indices.append(self.alphabet.index(x))
            except ValueError:
                raise KeyError(f"new alphabet contains unknown letter: {x!r}") from None

        for letter in alphabet:
            row = self[<str> letter]
            matrix.append([row[j] for j in indices])

        name = self.name if len(alphabet) == len(self.alphabet) else None
        return type(self)(matrix, alphabet=alphabet, name=name)
