# chnode

[![Build status](https://travis-ci.org/tkareine/chnode.svg?branch=master)][chnode-build]

Changes shell's current Node.js version by updating `$PATH`.

`chnode` is a lightweight Node.js version switcher that selects a
Node.js version for a shell session. The mechanism to do this is by
updating the `PATH` environment variable. Confining version switching to
a shell session allows you to run different Node.js versions in many
shell sessions simultaneously.

The lightweight design and small feature set makes `chnode` very fast to
load, having minimal negative effect on your shell's init script.

`chnode` expects that Node.js versions are already installed on your
system. It cannot download them for you. Instead, download Node.js
binaries manually or use another tool, such as [node-build], for the
job.

To read more about the design rationale and a comparison to [nvm] and
[nodenv], look [here][tkareine-lightweight-nodejs-version-switching].

`chnode` is inspired by [chruby], which is awesome.

## Features

* Selects Node.js version for a shell session by updating the `PATH`
  environment variable. Version switching is independent per shell
  session.
* Optional automatic Node.js version switching based on a
  `.node-version` file in your project directory.
* Small feature set by design, making the tool very fast to load.
* Each Node.js version has its own set of global npm packages.
* Allows accessing man pages for the selected Node.js version and its
  global npm packages.
* After switching Node.js version, calls `hash -r` to clear the hash
  table for program locations.
* Best candidate ("fuzzy") matching of Node.js versions at switching.
* The path to the selected Node.js version is available in `CHNODE_ROOT`
  environment variable. This makes it easy to display the selected
  version in shell prompt.
* Locates installed Node.js versions in `~/.nodes` directory, or from a
  custom directory read from `CHNODE_NODES_DIR` shell variable.
* Add additional Node.js versions by appending to `CHNODE_NODES` array
  shell variable.
* Works with Bash's `set -euo pipefail` shell options ("strict mode").
* Good test coverage.

## Requirements

[GNU Bash] version >= 3.2 or [Zsh] version >= 5.3

## Install

### Manual

The manual method just downloads the latest revision of [chnode.sh]
script:

``` shell
curl -L 'https://raw.githubusercontent.com/tkareine/chnode/master/chnode.sh' > chnode.sh
```

It's up to you to download the script again to update.

### Homebrew

[Homebrew] [tap][Homebrew-tap-chnode] is available for macOS users:

``` shell
brew tap tkareine/chnode
brew install tkareine/chnode/chnode
```

This is the easy way to install just the script and related
documentation, and to keep the script up-to-date.

### Git clone

Alternatively, clone the git repository:

``` shell
git clone --depth 1 git@github.com:tkareine/chnode.git
```

The downside of cloning is that you'll download all the non-essential
project files.

### Post-installation

Execute `source` command to load chnode functions:

``` bash
source chnode.sh
```

You may append the command above into your Bash init script,
`~/.bashrc`, to load chnode for your interactive shell usage.

Automatic Node.js version switching requires additional setup, read
below for more.

### Sourcing .bashrc on macOS

macOS does not execute `~/.bashrc` automatically when opening a
terminal. You might want to add the following line to `~/.bash_profile`
to fix it:

``` bash
[[ -r ~/.bashrc ]] && source ~/.bashrc
```

## Available Node.js versions

When shell loads `chnode` with `source` command, the script auto-detects
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

### Installing Node.js versions

You can use [node-build] to install Node.js binaries.

Installing to `~/.nodes`:

``` shell
node-build 10.11.0 ~/.nodes/node-10.11.0
```

Alternatively, download binaries from Node.js [download
page][nodejs-download] and extract them to `~/.nodes`:

``` shell
mkdir -p ~/.nodes/node-10.12.0 \
    && tar xzvf ~/Downloads/node-v10.12.0-darwin-x64.tar.gz --strip-components 1 -C ~/.nodes/node-10.12.0
```

### Default Node.js version (without auto switching)

Choose the default Node.js version in your shell's init script, here a
10.x series:

``` bash
source chnode.sh
chnode node-10
```

## Usage

**List** available Node.js versions:

```
$ chnode
   node-10.11.0
   node-8.11.4
```

**Select** a Node.js version, here a 10.x series:

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

While in the shell, install another Node.js version and **reload**
chnode (`chnode -R`):

```
$ node-build 8.9.4 ~/.nodes/node-8.9.4

$ chnode
 * node-10.11.0
   node-8.11.4

$ chnode -R  # or --reload

$ chnode
 * node-10.11.0
   node-8.11.4
   node-8.9.4
```

**Reset** the version (`chnode -r`), clearing the path that was set in
the `PATH` environment variable:

```
$ chnode -r  # or --reset

$ chnode
   node-10.11.0
   node-8.11.4
   node-8.9.4

$ echo "$PATH"
/usr/local/bin:/usr/bin:…
```

Show **usage**:

```
$ chnode -h  # or --help
```

Show **version**:

```
$ chnode -V  # or --version
```

## Automatic version switching

Automatic Node.js version switching is included in `auto.sh` script as
an optional add-on on top of `chnode.sh`. The feature detects a
`.node-version` file in your current working directory (or in a parent
directory), and switches the current Node.js version to the version
specified in the file. You'll need to have the specified version
installed for the switching to happen.

To use the feature, source `chnode.sh` and `auto.sh` (in this order) in
your shell's init script, and include `chnode_auto` function to be
called automatically in `PROMPT_COMMAND` (for Bash) or
`preexec_functions` (for Zsh):

``` bash
source chnode.sh
source auto.sh

PROMPT_COMMAND=chnode_auto        # if using Bash
preexec_functions+=(chnode_auto)  # if using Zsh
```

Note that you might already have commands to be evaluated in
`PROMPT_COMMAND` in Bash. In that case, you have options:

1. Wrap all the commands in a function, including `chnode_auto`, and make the function the `PROMPT_COMMAND`:

   ``` bash
   my_prompt_function() {
     # do somehing, like set PS1

     chnode_auto  # call last
   }

   PROMPT_COMMAND=my_prompt_function
   ```

2. Append `chnode_auto` to be called last in `PROMPT_COMMAND`:

   ``` bash
   PROMPT_COMMAND="$PROMPT_COMMAND; chnode_auto"
   ```

We don't recommend to evaluate `chnode_auto` via shell's DEBUG trap,
because it triggers calling the function too often (for example, for
each command in a command group). In addition, the trap might be used by
other shell functionality. To demonstrate the problem with command
groups:

``` bash
# WARNING: don't install chnode_auto like this, triggers likely too often for you
trap '[[ $BASH_COMMAND != "${PROMPT_COMMAND:-}" ]] && echo CALLED && chnode_auto' DEBUG

# enter in your shell:
$ { echo lol; echo bal; }  # calls the trap twice
CALLED
lol
CALLED
bal
```

To set a default node version for a project, create a `.node-version`
file in the root directory of the project:

``` bash
echo node-8.1.0 > node-project/.node-version
```

You can set a default for your whole system by adding `.node-version` to
your home directory.

## Display current Node.js in shell prompt

You can pick up the selected Node.js version from `CHNODE_ROOT`
environment variable. An example script to customize shell prompt is in
[set-prompt.sh]. Usage:

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
[node-build]: https://github.com/nodenv/node-build
[nodejs-download]: https://nodejs.org/en/download/current/
[nodenv]: https://github.com/nodenv/nodenv
[nvm]: https://github.com/creationix/nvm
[set-prompt.sh]: https://raw.githubusercontent.com/tkareine/chnode/master/contrib/set-prompt.sh
[tkareine-lightweight-nodejs-version-switching]: https://tkareine.org/articles/lightweight-nodejs-version-switching.html
