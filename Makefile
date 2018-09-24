SHELL := bash  # required for `help` target

SHELLCHECK_OPTS=

BM_FILES ?= $(wildcard benchmark/*-bm.sh)

.PHONY: help
help:
	@echo -e '$(subst $(newline),\n,$(usage_text))'

.PHONY: benchmark
benchmark:
	$(foreach bm,$(BM_FILES),./$(bm)$(newline))

.PHONY: lint
lint:
	shellcheck -s bash chnode.sh

define newline


endef

define usage_text
Targets:

  help         Show this guide
  benchmark    Run benchmarks
  lint         Run shellcheck on selected sources
endef
