# Releasing

1. Check that [CI] is green.

2. Double check that code linter and tests pass:

    ``` shell
    make lint-docker
    make test SHELL=bash  # if on macOS
    make test SHELL=zsh   # if on macOS
    make test-docker
    ```

3. Update `CHNODE_VERSION`:

    ``` shell
    $EDITOR chnode.sh
    ```

4. Summarize changes since the last release:

    ``` shell
    $EDITOR CHANGELOG.md
    ```

5. Review your changes, commit them, tag the release:

    ``` shell
    git diff
    git add -p
    git commit -m 'Release version $version'
    git tag v$version
    git push origin master v$version
    ```

6. Update [Homebrew tap][Homebrew-tap-chnode].

[CI]: https://github.com/tkareine/chnode/actions/workflows/ci.yml
[Homebrew-tap-chnode]: https://github.com/tkareine/homebrew-chnode
