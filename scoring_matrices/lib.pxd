cdef class ScoringMatrix:
    cdef readonly str name
    cdef readonly str alphabet

    cdef size_t        _size
    cdef Py_ssize_t[2] _shape

    cdef float*  _data
    cdef float** _matrix

    cdef int _allocate(self, size_t length) except 1 nogil

    cpdef float min(self)
    cpdef float max(self)
    cpdef ScoringMatrix copy(self)