# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


## [Unreleased]
[Unreleased]: https://github.com/althonos/scoring-matrices/compare/v0.3.4...HEAD


## [v0.3.4] - 2026-01-18
[v0.3.4]: https://github.com/althonos/scoring-matrices/compare/v0.3.3...v0.3.4

### Added
- New `buffer` attribute to `ScoringMatrix` exposing a unique read-only `memoryview`.
- `PFASUM` matrices ([#6](https://github.com/althonos/scoring-matrices/pull/6), by [@apcamargo](https://github.com/apcamargo)).
- `EDNAFULL` nucleotide matrix ([#7](https://github.com/althonos/scoring-matrices/pull/7), by [@apcamargo](https://github.com/apcamargo)).

### Changed
- Compile wheel in Python Limited API mode for Python 3.11 and later.

### Fixed
- Issue with `pickle` protocol 5 causing issues with `ScoringMatrix` pickling.
- Ensure documentation is built with extension in debug mode on ReadTheDocs.


## [v0.3.3] - 2025-08-13
[v0.3.3]: https://github.com/althonos/scoring-matrices/compare/v0.3.2...v0.3.3

### Fixed
- Memory leak caused by `ScoringMatrix` not deallocating data on object deletion.


## [v0.3.2] - 2025-06-16
[v0.3.2]: https://github.com/althonos/scoring-matrices/compare/v0.3.1...v0.3.2

### Fixed
- Exclude `docs` folder from source distribution, causing issues with Windows builds.


## [v0.3.1] - 2025-06-12
[v0.3.1]: https://github.com/althonos/scoring-matrices/compare/v0.3.0...v0.3.1

### Added
- 3di scoring matrix from Foldseek ([#5](https://github.com/althonos/scoring-matrices/pull/5), by [@apcamargo](https://github.com/apcamargo)).


## [v0.3.0] - 2024-10-20
[v0.3.0]: https://github.com/althonos/scoring-matrices/compare/v0.2.2...v0.3.0

### Changed
- Rewrite package build using `scikit-build-core`.
- Use the PyData theme in documentation.

### Removed
- Support for Python 3.6.


## [v0.2.2] - 2024-06-24
[v0.2.2]: https://github.com/althonos/scoring-matrices/compare/v0.2.1...v0.2.2

### Fixed
- Segmentation fault due to out-of-bounds access in `ScoringMatrix.is_symmetric` ([#2](https://github.com/althonos/scoring-matrices/issues/2)).


## [v0.2.1] - 2024-06-06
[v0.2.1]: https://github.com/althonos/scoring-matrices/compare/v0.2.0...v0.2.1

### Fixed
- Missing type hints of `name` and `alphabet` attributes of `ScoringMatrix` ([#1](https://github.com/althonos/scoring-matrices/pull/1), by [@RayHackett](https://github.com/RayHackett)).


## [v0.2.0] - 2024-05-06
[v0.2.0]: https://github.com/althonos/scoring-matrices/compare/v0.1.1...v0.2.0

### Added
- `ScoringMatrix.is_symmetric` method to check whether the matrix is symmetric.
- `ScoringMatrix.from_match_mismatch` and `ScoringMatrix.from_diagonal` constructors.

### Fixed
- Rounding of constants in generated `matrices.h` header.


## [v0.1.1] - 2024-05-03
[v0.1.1]: https://github.com/althonos/scoring-matrices/compare/v0.1.0...v0.1.1

### Fixed
- Compilation of Python Limited API wheels.


## [v0.1.0] - 2024-05-03
[v0.1.0]: https://github.com/althonos/scoring-matrices/compare/de079cc0...v0.1.0

Initial release.
