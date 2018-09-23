SHELL := bash  # required for `help` target
SHELLCHECK_OPTS=

.PHONY: help
help:
	@echo -e '$(subst $(newline),\n,$(usage_text))'

.PHONY: lint
lint:
	shellcheck -s bash chnode.sh

define newline


endef

define usage_text
Targets:

  help    Show this guide.
  lint    Run shellcheck on selected sources.
endef
