``scoring-matrices`` |Stars|
============================

.. |Stars| image:: https://img.shields.io/github/stars/althonos/scoring-matrices.svg?style=social&maxAge=3600&label=Star
   :target: https://github.com/althonos/scoring-matrices/stargazers

*Dependency free, Cython-compatible scoring matrices to use with biological sequences.*

|Actions| |Coverage| |PyPI| |Bioconda| |AUR| |Wheel| |Versions| |Implementations| |License| |Source| |Issues| |Docs| |Changelog| |Downloads|

.. |Actions| image:: https://img.shields.io/github/actions/workflow/status/althonos/scoring-matrices/test.yml?branch=main&logo=github&style=flat-square&maxAge=300
   :target: https://github.com/althonos/scoring-matrices/actions

.. |Coverage| image:: https://img.shields.io/codecov/c/gh/althonos/scoring-matrices?style=flat-square&maxAge=600
   :target: https://codecov.io/gh/althonos/scoring-matrices/

.. |PyPI| image:: https://img.shields.io/pypi/v/scoring-matrices.svg?style=flat-square&maxAge=3600
   :target: https://pypi.python.org/pypi/scoring-matrices

.. |Bioconda| image:: https://img.shields.io/conda/vn/bioconda/scoring-matrices?style=flat-square&maxAge=3600
   :target: https://anaconda.org/bioconda/scoring-matrices

.. |AUR| image:: https://img.shields.io/aur/version/python-scoring-matrices?logo=archlinux&style=flat-square&maxAge=3600
   :target: https://aur.archlinux.org/packages/python-scoring-matrices

.. |Wheel| image:: https://img.shields.io/pypi/wheel/scoring-matrices?style=flat-square&maxAge=3600
   :target: https://pypi.org/project/scoring-matrices/#files

.. |Versions| image:: https://img.shields.io/pypi/pyversions/scoring-matrices.svg?style=flat-square&maxAge=3600
   :target: https://pypi.org/project/scoring-matrices/#files

.. |Implementations| image:: https://img.shields.io/pypi/implementation/scoring-matrices.svg?style=flat-square&maxAge=3600&label=impl
   :target: https://pypi.org/project/scoring-matrices/#files

.. |License| image:: https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square&maxAge=3600
   :target: https://choosealicense.com/licenses/mit/

.. |Source| image:: https://img.shields.io/badge/source-GitHub-303030.svg?maxAge=2678400&style=flat-square
   :target: https://github.com/althonos/scoring-matrices/

.. |Issues| image:: https://img.shields.io/github/issues/althonos/scoring-matrices.svg?style=flat-square&maxAge=600
   :target: https://github.com/althonos/scoring-matrices/issues

.. |Docs| image:: https://img.shields.io/readthedocs/scoring-matrices?style=flat-square&maxAge=3600
   :target: http://scoring-matrices.readthedocs.io/en/stable/?badge=stable

.. |Changelog| image:: https://img.shields.io/badge/keep%20a-changelog-8A0707.svg?maxAge=2678400&style=flat-square
   :target: https://github.com/althonos/scoring-matrices/blob/main/CHANGELOG.md

.. |Downloads| image:: https://img.shields.io/pypi/dm/scoring-matrices?style=flat-square&color=303f9f&maxAge=86400&label=downloads
   :target: https://pepy.tech/project/scoring-matrices


.. currentmodule:: scoring_matrices


Overview
--------

*Scoring Matrices* are matrices used to score the matches and mismatches between
two characters are the same position in a sequence alignment. Some of these
matrices are derived from *substitution matrices*, which uses evolutionary 
modeling.

The ``scoring-matrices`` package is a dependency-free, batteries included 
Cython library to handle and distribute common substitution matrices:

.. grid:: 1 2 3 3
   :gutter: 1

   .. grid-item-card:: :fas:`box` Self-contained

      The matrices are distributed as-is: you don't need the whole 
      `Biopython <https://biopython.org>`_ ecosystem, or even 
      `NumPy <https://numpy.org/>`_.
   
   .. grid-item-card:: :fas:`gears` Cython Support

      The `ScoringMatrix` class is a Cython class that can be
      inherited, and the matrix data can be accessed as either a raw pointer, or
      a `typed memoryview <https://cython.readthedocs.io/en/latest/src/userguide/memoryviews.html>`_.

   .. grid-item-card:: :fas:`battery-full` Batteries-included

      The package distributes most common matrices, such as those used by 
      the NCBI BLAST+ suite, including: *PAM*, *BLOSUM*, *VTML*, *BENNER*,
      etc.

   .. grid-item-card:: :fas:`file-import` I/O Support

      Easily load a `ScoringMatrix` from a file, a file-like object, or by
      name for common matrices.

   .. grid-item-card:: :fas:`screwdriver-wrench` Configurable

      Easily build your own scoring matrices using the Python interface,
      including various shortcut constructors to create a `ScoringMatrix`
      from a diagonal or a pair of match/mismatch scores.

   .. grid-item-card:: :fas:`stamp` Versioned

      This library follows semantic versioning to guarantee compatibility 
      between patch versions, allowing for a safe API and ABI that can be
      reused without recompiling on each install. 


Setup
-----

``scoring-matrices`` is available for all modern Python versions (3.7+).

Run ``pip install scoring-matrices`` in a shell to download the latest release 
from PyPi, or have a look at the :doc:`Installation page <guide/install>` to find 
other ways to install the package.


Library
-------

.. toctree::
   :maxdepth: 2

   User Guide <guide/index>
   API Reference <api/index>


Related Projects
----------------

The following Python libraries may be of interest for bioinformaticians.

.. grid:: 1 3 5 5
   :gutter: 1

   .. grid-item-card:: :fas:`diamond` PyHMMER
      :link: https://pyhmmer.readthedocs.io

      Profile Hidden Markov Models (with HMMER).

   .. grid-item-card:: :fas:`fire` Pyrodigal
      :link: https://pyrodigal.readthedocs.io

      Prokaryotic Gene Finding (with Prodigal).

   .. grid-item-card:: :fas:`virus-covid` Pyrodigal-gv
      :link: https://github.com/althonos/pyrodigal-gv

      Pyrodigal for Giant Viruses.

   .. grid-item-card:: :fas:`align-center` PyFAMSA
      :link: https://pyfamsa.readthedocs.io

      Multiple Sequence Alignment (with FAMSA).

   .. grid-item-card:: :fas:`scissors` PytrimAl
      :link: https://pytrimal.readthedocs.io

      Alignment Trimming (with trimAl).

   .. grid-item-card:: :fas:`music` LightMotif
      :link: https://lightmotif.readthedocs.io

      Platform-accelerated motif scoring.

   .. grid-item-card:: :fas:`knife;fa-custom` Diced
      :link: https://diced.readthedocs.io

      CRISPR Detection (with MinCED).

   .. grid-item-card:: :fas:`table-cells` Scoring Matrices
      :link: https://scoring-matrices.readthedocs.io

      Scoring matrices for Cython.

   .. grid-item-card:: :fas:`chain` Pyskani
      :link: https://pyskani.readthedocs.io

      Average Nucleotide Identity (with skani).

   .. grid-item-card:: :fas:`forward-fast` PyFastANI
      :link: https://pyfastani.readthedocs.io

      Average Nucleotide Identity (with FastANI).

   .. grid-item-card:: :fas:`magnifying-glass` PyJess
      :link: https://pyjess.readthedocs.io

      Geometric Template Matching (with Jess).

   .. grid-item-card:: :fas:`repeat` PyTantan
      :link: https://pytantan.readthedocs.io

      Tandem Repeat Masking (with Tantan).

   .. grid-item-card:: :fas:`gem` PyOpal
      :link: https://pyopal.readthedocs.io

      Query/Database Aligner (with Opal).

   .. grid-item-card:: :fas:`sword;fa-custom` PySWRD
      :link: https://pyswrd.readthedocs.io

      Database Heuristic Filtering (with SWORD).

   .. grid-item-card:: :fas:`rocket` Mini3di
      :link: https://github.com/althonos/mini3di

      Protein structure to 3di in pure Python.

   .. grid-item-card:: :fas:`calculator` ``peptides.py``
      :link: https://peptides.readthedocs.io

      Peptide descriptors for Python.

   .. grid-item-card:: :fas:`diagram-project` Pronto
      :link: https://pronto.readthedocs.io

      Open Biomedical Ontologies for Python.

   .. grid-item-card:: :fas:`box` NAFcodec
      :link: https://nafcodec.readthedocs.io

      Nucleotide Archival Format for Python.

   .. grid-item-card:: :fas:`bank` ``gb-io.py``
      :link: https://gb-io.readthedocs.io

      Fast GenBank parser for Python (with ``gb-io``).


License
-------

This library is provided under the `MIT License <https://choosealicense.com/licenses/mit/>`_.
Matrices were collected from the `MMseqs2 <https://github.com/soedinglab/MMseqs2>`_,
`Biopython <https://github.com/biopython/biopython/tree/master/Bio/Align/substitution_matrices/data>`_
and `NCBI BLAST+ <https://ftp.ncbi.nih.gov/blast/matrices/>`_ sources and are believed to
be in the public domain.

*This project was developed by* `Martin Larralde <https://github.com/althonos/>`_
*during his PhD project at the* `Leiden University Medical Center <https://www.lumc.nl/en/>`_
*in the* `Zeller team <https://github.com/zellerlab>`_.
