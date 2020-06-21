## v0.3.1 / 2019-11-10

* Ensure using external utility for `ls` when checking the non-emptiness
  of `CHNODE_NODES_DIR` (avoid calling function or alias for `ls`).

## v0.3.0 / 2019-08-28

* Add support for automatic Node.js version switching by detecting
  `.node-version` file and switching to the version specified in the
  file automatically. Implemented as an optional add-on by sourcing
  `auto.sh` and installing a hook into shell. Pull Request #2 by James
  Buckley (@donquxiote).

## v0.2.0 / 2018-10-07

* Breaking change: rename `chnode reset` to `chnode -r`. Rationale:
  disallow word commands in order to avoid clashes with Node.js
  versions, selectable with `chnode NODE_VERSION`.
* Add `chnode -R` to reload chnode, allowing detecting new and removed
  Node.js versions in `CHNODE_NODES_DIR`.
* Code refactor.

## v0.1.0 / 2018-09-30

* First release.
