``ScoringMatrix``
=================

.. currentmodule:: scoring_matrices


.. autoclass:: ScoringMatrix
   :members:

   .. c:function:: const float* data_ptr()

      Get a pointer to the scoring matrix as a C-contiguous array.

   .. c:function:: const float** matrix_ptr()

      Get a pointer to the scoring matrix as an array of pointers to matrix rows.

   .. c:function:: const char* alphabet_ptr()

      Get a pointer to the scoring matrix alphabet as a C-string.

   .. c:function:: size_t size()

      Get the size of the scoring matrix.

   .. automethod:: __init__

   .. automethod:: __len__

   .. automethod:: __getitem__

   .. automethod:: __copy__

   .. automethod:: __eq__

   .. automethod:: __reduce_ex__
   