# chnode

[![Build status](https://travis-ci.org/tkareine/chnode.svg?branch=master)][chnode-build]

Changes shell's current Node.js by updating `$PATH`.

Inspired by [chruby], which is awesome.

## Features

* Updates `PATH` environment variable.
* Avoids executable shims, hooking to `cd`, and all the problems
  associated with those.
* The man pages of Node.js and npm packages for the selected Node.js are
  available.
* Calls `hash -r` to clear the hash table for program locations.
* Best candidate matching of Node.js installations by name.
* The path to current Node.js version is available in `CHNODE_ROOT`
  environment variable. This makes it easy to display it in shell
  prompt.
* Locate your Node.js versions in `~/.nodes` directory. Set custom
  directory with `CHNODE_NODES_DIR` shell variable.
* Add additional Node.js versions by adding to `CHNODE_NODES` array
  shell variable.
* Small and fast.

## Requirements

[GNU Bash] version >= 3.2 or [Zsh] version >= 5.3

## Installation

### Manual

The manual method just downloads the latest revision of [chnode.sh]
script:

``` shell
curl -L 'https://raw.githubusercontent.com/tkareine/chnode/master/chnode.sh' > chnode.sh
```

It's up to you to download the script again to update.

### Homebrew tap

[Homebrew] [tap][Homebrew-tap-chnode] is available for macOS users:

``` shell
brew tap tkareine/chnode
brew install tkareine/chnode/chnode
```

This is the easy way to install just the script and related
documentation, and to keep the script up-to-date.

### Git clone

Alternatively, clone the repository:

``` shell
git clone git@github.com:tkareine/chnode.git
```

The downside of cloning is that you'll download all the non-essential
project files.

### Post-installation

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

When shell loads chnode with `source` command, the script auto-detects
Node.js versions installed in `~/.nodes` directory.

You may override `~/.nodes` directory by setting `CHNODE_NODES_DIR`
shell variable to point to another directory. Do this before executing
the `source` command. For example:

``` bash
CHNODE_NODES_DIR=/opt/nodes
source chnode.sh
```

Sourcing `chnode.sh` populates `CHNODE_NODES` shell array variable with
paths to subdirectories in `CHNODE_NODES_DIR`. `CHNODE_NODES` contains
the Node.js versions you can select with `chnode NODE_VERSION` command.

After installing new Node.js versions or removing them, run `chnode -R`
to populate `CHNODE_NODES` again.

For Node.js versions installed in other locations, add their paths to
`CHNODE_NODES` after the `source` or `chnode -R` commands. For example:

``` bash
source chnode.sh
CHNODE_NODES+=(/opt/node-10.11.0)
```

### node-build

You can use [node-build] to install Node.js versions.

Installing to `~/.nodes`:

``` shell
node-build 10.11.0 ~/.nodes/node-10.11.0
```

### Default Node.js version

Choose the default Node.js version in your shell's init script, here a
10.x series:

``` bash
source chnode.sh
chnode node-10
```

## Usage

List available Node.js versions:

```
$ chnode
   node-10.11.0
   node-8.11.4
```

Select a Node.js version, here a 10.x series:

```
$ chnode node-10

$ chnode
 * node-10.11.0
   node-8.11.4

$ echo "$PATH"
/Users/tkareine/.nodes/node-10.11.0/bin:/usr/local/bin:/usr/bin:…

$ echo "$CHNODE_ROOT"
/Users/tkareine/.nodes/node-10.11.0
```

Open the man page of [marked], installed as global npm package:

```
$ npm install -g marked

$ man -w marked
/Users/tkareine/.nodes/node-10.11.0/share/man/man1/marked.1

$ man marked
```

While in the shell, install another Node.js and reload chnode (`chnode
-R`):

```
$ node-build 8.9.4 ~/.nodes/node-8.9.4

$ chnode
 * node-10.11.0
   node-8.11.4

$ chnode -R

$ chnode
 * node-10.11.0
   node-8.11.4
   node-8.9.4
```

Reset the version (`chnode -r`), clearing the path that was set in
`$PATH`:

```
$ chnode -r

$ chnode
   node-10.11.0
   node-8.11.4
   node-8.9.4

$ echo "$PATH"
/usr/local/bin:/usr/bin:…
```

Show usage:

```
$ chnode -h
```

## Display current Node.js in shell prompt

You can pick up the currently selected Node.js version from
`CHNODE_ROOT` environment variable. An example script to customize shell
prompt is in [set-prompt.sh]. Usage:

```
$ source chruby.sh
$ source contrib/set-prompt.sh
[tkareine@sky] [~/Projects/chnode] (node:10.11.0)
$
```

## License

MIT. See [LICENSE.txt].

[GNU Bash]: https://www.gnu.org/software/bash/
[Homebrew-tap-chnode]: https://github.com/tkareine/homebrew-chnode
[Homebrew]: https://brew.sh/
[LICENSE.txt]: https://raw.githubusercontent.com/tkareine/chnode/master/LICENSE.txt
[Zsh]: https://www.zsh.org/
[chnode-build]: https://travis-ci.org/tkareine/chnode
[chnode.sh]: https://raw.githubusercontent.com/tkareine/chnode/master/chnode.sh
[chruby]: https://github.com/postmodern/chruby
[marked]: https://github.com/markedjs/marked
[node-build]: https://github.com/nodenv/node-build
[set-prompt.sh]: https://raw.githubusercontent.com/tkareine/chnode/master/contrib/set-prompt.sh
