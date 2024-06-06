# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


## [Unreleased]
[Unreleased]: https://github.com/althonos/scoring-matrices/compare/v0.2.1...HEAD


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
