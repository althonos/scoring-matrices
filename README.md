# 🧬🔠 `scoring-matrices` [![Stars](https://img.shields.io/github/stars/althonos/scoring-matrices.svg?style=social&maxAge=3600&label=Star)](https://github.com/althonos/scoring-matrices/stargazers)

*Dependency free, [Cython](https://cython.org/)-compatible scoring matrices to use with biological sequences.*

[![Actions](https://img.shields.io/github/actions/workflow/status/althonos/scoring-matrices/test.yml?branch=main&logo=github&style=flat-square&maxAge=300)](https://github.com/althonos/scoring-matrices/actions)
[![Coverage](https://img.shields.io/codecov/c/gh/althonos/scoring-matrices?style=flat-square&maxAge=3600&logo=codecov)](https://codecov.io/gh/althonos/scoring-matrices/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square&maxAge=2678400)](https://choosealicense.com/licenses/mit/)
[![PyPI](https://img.shields.io/pypi/v/scoring-matrices.svg?style=flat-square&maxAge=3600&logo=PyPI)](https://pypi.org/project/scoring-matrices)
[![Bioconda](https://img.shields.io/conda/vn/bioconda/scoring-matrices?style=flat-square&maxAge=3600&logo=anaconda)](https://anaconda.org/bioconda/scoring-matrices)
[![AUR](https://img.shields.io/aur/version/python-scoring-matrices?logo=archlinux&style=flat-square&maxAge=3600)](https://aur.archlinux.org/packages/python-scoring-matrices)
[![Wheel](https://img.shields.io/pypi/wheel/scoring-matrices.svg?style=flat-square&maxAge=3600)](https://pypi.org/project/scoring-matrices/#files)
[![Python Versions](https://img.shields.io/pypi/pyversions/scoring-matrices.svg?style=flat-square&maxAge=600&logo=python)](https://pypi.org/project/scoring-matrices/#files)
[![Python Implementations](https://img.shields.io/pypi/implementation/scoring-matrices.svg?style=flat-square&maxAge=600&label=impl)](https://pypi.org/project/scoring-matrices/#files)
[![Source](https://img.shields.io/badge/source-GitHub-303030.svg?maxAge=2678400&style=flat-square)](https://github.com/althonos/scoring-matrices/)
[![Issues](https://img.shields.io/github/issues/althonos/scoring-matrices.svg?style=flat-square&maxAge=600)](https://github.com/althonos/scoring-matrices/issues)
[![Docs](https://img.shields.io/readthedocs/scoring-matrices/latest?style=flat-square&maxAge=600)](https://scoring-matrices.readthedocs.io)
[![Changelog](https://img.shields.io/badge/keep%20a-changelog-8A0707.svg?maxAge=2678400&style=flat-square)](https://github.com/althonos/scoring-matrices/blob/main/CHANGELOG.md)
[![Downloads](https://img.shields.io/pypi/dm/scoring-matrices?style=flat-square&color=303f9f&maxAge=86400&label=downloads)](https://pepy.tech/project/scoring-matrices)

## 🗺️ Overview

*Scoring Matrices* are matrices used to score the matches and mismatches between
two characters are the same position in a sequence alignment. Some of these
matrices are derived from *substitution matrices*, which uses evolutionary 
modeling.

The `scoring-matrices` package is a dependency-free, batteries included library
to handle and distribute common substitution matrices:

- **no external dependencies**: The matrices are distributed as-is: you don't 
  need the whole [Biopython](https://biopython.org) ecosystem, or even 
  [NumPy](https://numpy.org/).
- **Cython compatibility**: The `ScoringMatrix` is a Cython class that can be
  inherited, and the matrix data can be accessed as either a raw pointer, or
  a [typed memoryview](https://cython.readthedocs.io/en/latest/src/userguide/memoryviews.html).
- **most common matrices**: The package distributes most common matrices, such as 
  those used by the NCBI BLAST+ suite, including:
  - [*PAM*](https://en.wikipedia.org/wiki/Point_accepted_mutation#) matrices by Dayhoff *et al.* (1978).
  - [*BLOSUM*](https://en.wikipedia.org/wiki/BLOSUM) matrices by Henikoff & Henikoff (1992).
  - *VTML* matrices by Muller *et al.* (2002).
  - *BENNER* matrices by Benner *et al.* (1994).

## 🔧 Installing

`scoring-matrices` can be installed directly from [PyPI](https://pypi.org/project/scoring-matrices/),
which hosts some pre-built wheels for the x86-64 architecture (Linux/OSX/Windows)
and the Aarch64 architecture (Linux/OSX), as well as the code required to
compile from source with Cython:
```console
$ pip install scoring-matrices
```

Otherwise, `scoring-matrices` is also available as a [Bioconda](https://bioconda.github.io/)
package:
```console
$ conda install bioconda::scoring-matrices
```

## 💡 Usage

### Python

- Import the `ScoringMatrix` class from the installed module:
  ```python
  from scoring_matrices import ScoringMatrix
  ```
- Load one of the built-in matrices:
  ```python
  blosum62 = ScoringMatrix.from_name("BLOSUM62")
  ```
- Get individual matrix weights either by index or by alphabet letter:
  ```python
  x = blosum62[0, 0]
  y = blosum62['A', 'A']
  ```
- Get a row of the matrix either by index or by alphabet letter:
  ```python
  row_x = blosum62[0]
  row_y = blosum62['A']
  ```

### Cython

- Access the matrix weights as raw pointers to constant data:
  ```cython
  from scoring_matrices cimport ScoringMatrix

  cdef ScoringMatrix blosum = ScoringMatrix.from_name("BLOSUM62")
  cdef const float*  data   = blosum.data()    # dense array
  cdef const float** matrix = blosum.matrix()  # array of pointers
  ```
- Access the `ScoringMatrix` weights as a [typed memoryview](https://cython.readthedocs.io/en/latest/src/userguide/memoryviews.html) 
  using the *buffer protocol* in more recents versions of Python:
  ```cython
  from scoring_matrices cimport ScoringMatrix

  cdef ScoringMatrix     blosum  = ScoringMatrix.from_name("BLOSUM62")
  cdef const float[:, :] weights = blosum
  ```

## 💭 Feedback

### ⚠️ Issue Tracker

Found a bug ? Have an enhancement request ? Head over to the [GitHub issue tracker](https://github.com/althonos/scoring-matrices/issues)
if you need to report or ask something. If you are filing in on a bug,
please include as much information as you can about the issue, and try to
recreate the same bug in a simple, easily reproducible situation.

### 🏗️ Contributing

Contributions are more than welcome! See
[`CONTRIBUTING.md`](https://github.com/althonos/scoring-matrices/blob/main/CONTRIBUTING.md)
for more details.


## 📋 Changelog

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html)
and provides a [changelog](https://github.com/althonos/scoring-matrices/blob/main/CHANGELOG.md)
in the [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) format.


## ⚖️ License

This library is provided under the [MIT License](https://choosealicense.com/licenses/mit/). 
Matrices were collected from the [MMseqs2](https://github.com/soedinglab/MMseqs2), 
[Biopython](https://github.com/biopython/biopython/tree/master/Bio/Align/substitution_matrices/data)
and [NCBI BLAST+](https://ftp.ncbi.nih.gov/blast/matrices/) sources and are believed to 
be in the public domain.

*This project was developed by [Martin Larralde](https://github.com/althonos/) 
during his PhD project at the [Leiden University Medical Center](https://www.lumc.nl/en/) in the [Zeller team](https://github.com/zellerlab).*
