# chnode

Changes shell's current Node.js by updating `$PATH`.

Inspired by [chruby], which is awesome.

Caution: work in progress.

## Features

* Updates `$PATH`
* Avoids executable shims, hooking to `cd`, and all the problems
  associated with those
* The man pages of Node.js and npm packages for the selected Node.js are
  available
* Calls `hash -r` to clear the command-lookup hash-table
* Fuzzy matching of Node.js installations by name
* Small and fast

## Requirements

Bash version >= 3

## Installation

For now, download the [chnode.sh] script:

``` shell
curl 'https://raw.githubusercontent.com/tkareine/chnode/master/chnode.sh' > chnode.sh
```

Or clone the repository:

``` shell
git clone git@github.com:tkareine/chnode.git
```

Execute `source` command to load chnode functions:

``` bash
source chnode.sh
```

You may append the command above into your bash init script,
`~/.bashrc`.

macOS does not execute `~/.bashrc` automatically. You might want to add
the following line to `~/.bash_profile`:

``` bash
[[ -r ~/.bashrc ]] && source ~/.bashrc
```

## Node.js versions

When shell loads chnode with `source` command, it will auto-detect
Node.js versions installed in `~/.nodes` directory.

You may override `~/.nodes` directory by setting `CHNODE_NODES_DIR`
environment variable to point to another directory. Do this before
executing the `source` command. For example:

``` bash
CHNODE_NODES_DIR=/opt/nodes
source chnode.sh
```

After installing new Node.js versions, you must restart your shell or
execute the `source` command again in order for chnode to detect them.

For Node.js versions installed in other locations, append their paths to
the `CHNODE_NODES` environment variable after the `source` command. For
example:

``` bash
source chnode.sh
CHNODE_NODES+=(/opt/node-10.10.0)
```

### node-build

You can use [node-build] to install Node.js versions.

Installing to `~/.nodes`:

``` shell
node-build 10.10.0 ~/.nodes/node-10.10.0
```

### Default Node.js version

Choose the default Node.js version in your shell's init script:

``` bash
source chnode.sh
chnode node-10
```

## Usage

List available Node.js versions:

```
$ chnode
   node-10.10.0
   node-8.11.4
```

Select a Node.js version, here a 10.x series:

```
$ chnode node-10

$ chnode
 * node-10.10.0
   node-8.11.4

$ echo "$PATH"
/Users/tkareine/.nodes/node-10.10.0/bin:/usr/local/bin:/usr/bin:…
```

Open the man page of [marked], installed as global npm package:

```
$ npm install -g marked
$ man marked
```

Reset the version, clearing the path that was set in `$PATH`:

```
$ chnode reset

$ chnode
   node-10.10.0
   node-8.11.4

$ echo "$PATH"
/usr/local/bin:/usr/bin:…
```

[chnode.sh]: https://raw.githubusercontent.com/tkareine/chnode/master/chnode.sh
[chruby]: https://github.com/postmodern/chruby
[marked]: https://github.com/markedjs/marked
[node-build]: https://github.com/nodenv/node-build
