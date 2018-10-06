## 0.2.0 / 2018-10-07

* Breaking change: rename `chnode reset` to `chnode -r`. Rationale:
  disallow word commands in order to avoid clashes with Node.js
  versions, selectable with `chnode NODE_VERSION`.
* Add `chnode -R` to reload chnode, allowing detecting new and removed
  Node.js versions in `CHNODE_NODES_DIR`.
* Code refactor.

## 0.1.0 / 2018-09-30

* First release.
