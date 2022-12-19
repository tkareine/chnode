# Changelog

This project adheres to [Semantic Versioning].

## [Unreleased]

## [v0.4.2] - 2022-10-07

### Changed

* Fix not attempting to populate the `CHNODE_NODES` shell array variable
  when the `CHNODE_NODES_DIR` contains just dotfiles.

### Added

* Readme: more details about how to install Node.js versions
* Readme: instruct configuring the prefix path for `npm`

## [v0.4.1] - 2022-05-29

### Changed

* Change parsing of the `.node-version` file in the `chnode_auto`
  function to be more forgiving (allow missing trailing newline, allow
  Windows style line endings, trim the leading `v` character if followed
  by a digit). Issue #5 by John Gee (@shadowspawn).

## [v0.4.0] - 2021-05-03

### Added

* Introduce the `CHNODE_AUTO_VERSION_FILENAME` shell variable to change
  the name the files used in detecting automatic version switching. The
  default value of the variable is `.node-version`.

### Changed

* Fix ignoring a `.node-version` file containing just a
  newline. Document file format specification in the readme.

## [v0.3.1] - 2019-11-10

### Changed

* Ensure using external utility for `ls` when checking the non-emptiness
  of `CHNODE_NODES_DIR` (avoid calling function or alias for `ls`).

## [v0.3.0] - 2019-08-28

### Added

* Add support for automatic Node.js version switching by detecting
  `.node-version` file and switching to the version specified in the
  file automatically. Implemented as an optional add-on by sourcing
  `auto.sh` and installing a hook into shell. Pull Request #2 by James
  Buckley (@donquxiote).

## [v0.2.0] - 2018-10-07

### Added

* Add `chnode -R` to reload chnode, allowing detecting new and removed
  Node.js versions in `CHNODE_NODES_DIR`.

### Changed

* **Breaking:** rename `chnode reset` to `chnode -r`. Rationale:
  disallow word commands in order to avoid clashes with Node.js
  versions, selectable with `chnode NODE_VERSION`.
* Code refactor.

## [v0.1.0] - 2018-09-30

### Added

* First release.

[Semantic Versioning]: https://semver.org/spec/v2.0.0.html
[Unreleased]: https://github.com/tkareine/chnode/compare/v0.4.2...HEAD
[v0.4.2]: https://github.com/tkareine/chnode/compare/v0.4.1...v0.4.2
[v0.4.1]: https://github.com/tkareine/chnode/compare/v0.4.0...v0.4.1
[v0.4.0]: https://github.com/tkareine/chnode/compare/v0.3.1...v0.4.0
[v0.3.1]: https://github.com/tkareine/chnode/compare/v0.3.0...v0.3.1
[v0.3.0]: https://github.com/tkareine/chnode/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/tkareine/chnode/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/tkareine/chnode/releases/tag/v0.1.0
