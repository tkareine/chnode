SHELL := bash  # required for `help` target

SHELLCHECK_OPTS := -s bash -e SC1090 -e SC1091

TEST_FILES ?= $(wildcard test/*-test.sh)

BM_FILES ?= $(wildcard benchmark/*-bm.sh)

DOCKER_TEST_BASHES ?= bash-4.4 bash-3.2

LINT_FILES := \
    chnode.sh \
    support/fixture.sh \
    support/shell-info.sh \
    benchmark/runner.sh \
    test/helper.sh \
    test/runner.sh \
    $(TEST_FILES) \
    $(BM_FILES)

.PHONY: help
help:
	@echo -e '$(subst $(newline),\n,$(usage_text))'

.PHONY: lint
lint:
	shellcheck $(LINT_FILES)

.PHONY: test
test:
	./test/runner.sh $(TEST_FILES)

.PHONY: test-docker
test-docker: $(DOCKER_TEST_BASHES)

.PHONY: $(DOCKER_TEST_BASHES)
$(DOCKER_TEST_BASHES):
	docker run \
	    -it \
	    -v "$(CURDIR):/chnode" \
	    -e SHELL=/usr/local/bin/bash \
	    $(subst -,:,$@) \
	    bash -c 'cd /chnode && ./test/runner.sh $(TEST_FILES)'

.PHONY: benchmark
benchmark:
	./benchmark/runner.sh $(BM_FILES)

define newline


endef

define usage_text
Targets:

  help         Show this guide
  lint         Run shellcheck on source files
  test         Run tests (select: TEST_FILES=test/*-test.sh)
  test-docker  Run tests with various shells in Docker container (select: TEST_FILES=test/*-test.sh)
  benchmark    Run benchmarks (select: BM_FILES=benchmark/*-bm.sh)
endef
