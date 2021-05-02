export SHELL

SHELLCHECK_OPTS := -s bash -e SC1090 -e SC1091

TEST_FILES ?= $(wildcard test/*-test.sh)

BM_FILES ?= $(wildcard benchmark/*-bm.sh)

DOCKER_TEST_BASHES ?= bash!5 bash!4.4 bash!3.2
DOCKER_TEST_ZSHES ?= zshusers/zsh!5.8 zshusers/zsh!5.6.2 zshusers/zsh!5.3

LINT_FILES := chnode.sh auto.sh $(wildcard benchmark/*.sh support/*.sh test/*.sh)

PREFIX ?= /usr/local
SHARE_DIR := $(PREFIX)/share
CHNODE_SHARE_DIR := $(SHARE_DIR)/chnode
CHNODE_SHARE_SOURCES := chnode.sh auto.sh
CHNODE_DOC_DIR := $(SHARE_DIR)/doc/chnode
CHNODE_DOC_SOURCES := CHANGELOG.md LICENSE.txt README.md

.PHONY: help
help: SHELL := bash
help:
	@echo -e "$(subst $(newline),\n,$(usage_text))"

.PHONY: lint
lint:
	shellcheck $(LINT_FILES)

.PHONY: lint-docker
lint-docker:
	docker run \
	    --rm \
	    -t \
	    -v "$(CURDIR):/chnode" \
	    -w /chnode \
	    -e SHELLCHECK_OPTS="$(SHELLCHECK_OPTS)" \
	    koalaman/shellcheck:stable \
	    $(LINT_FILES)

test/shunit2/shunit2:
	$(git-submodule-reset)

.PHONY: test
test: test/shunit2/shunit2
	$(SHELL) test/runner.sh $(TEST_FILES)

.PHONY: test-docker
test-docker: test-docker-bashes test-docker-zshes

.PHONY: test-docker-bashes
test-docker-bashes: $(DOCKER_TEST_BASHES)

.PHONY: test-docker-zshes
test-docker-zshes: $(DOCKER_TEST_ZSHES)

.PHONY: $(DOCKER_TEST_BASHES)
$(DOCKER_TEST_BASHES): test/shunit2/shunit2
	docker run \
	    --rm \
	    -t \
	    -v "$(CURDIR):/chnode" \
	    -w /chnode \
	    -e SHELL=/usr/local/bin/bash \
	    $(subst !,:,$@) \
	    bash test/runner.sh $(TEST_FILES)

.PHONY: $(DOCKER_TEST_ZSHES)
$(DOCKER_TEST_ZSHES): test/shunit2/shunit2
	docker run \
	    --rm \
	    -t \
	    -v "$(CURDIR):/chnode" \
	    -w /chnode \
	    -e SHELL=/usr/bin/zsh \
	    $(subst !,:,$@) \
	    zsh test/runner.sh $(TEST_FILES)

.PHONY: benchmark
benchmark:
	$(SHELL) benchmark/runner.sh $(BM_FILES)

.PHONY: install
install:
	mkdir -p "$(DESTDIR)$(CHNODE_SHARE_DIR)"
	cp $(CHNODE_SHARE_SOURCES) "$(DESTDIR)$(CHNODE_SHARE_DIR)/"
	mkdir -p "$(DESTDIR)$(CHNODE_DOC_DIR)"
	cp $(CHNODE_DOC_SOURCES) "$(DESTDIR)$(CHNODE_DOC_DIR)/"

.PHONY: uninstall
uninstall:
	rm -rf "$(DESTDIR)$(CHNODE_SHARE_DIR)"
	rm -rf "$(DESTDIR)$(CHNODE_DOC_DIR)"
	rmdir "$(SHARE_DIR)/doc" || true
	rmdir "$(SHARE_DIR)" || true

define newline


endef

define usage_text
Targets:

  help                Show this guide

  lint                Run shellcheck on source files
  lint-docker         Run shellcheck on source files in Docker container

  test                Run tests with SHELL you choose (usage: \`make test SHELL=bash\`) (select: TEST_FILES=test/*-test.sh)
  test-docker         Run tests with various bash and zsh versions in Docker container
  test-docker-bashes  Run tests with various bash versions in Docker container
  test-docker-zshes   Run tests with various zsh versions in Docker container

  benchmark           Run benchmarks with SHELL you choose (usage: \`make benchmark SHELL=bash\`) (select: BM_FILES=benchmark/*-bm.sh; iterations: N=1000; runs: RUNS=3)

  install             Copy chnode.sh and auto.sh and its documentation to PREFIX directory
  uninstall           Remove chnode.sh and auto.sh and its documentation from PREFIX directory
endef

git-submodule-reset := git submodule init; git submodule update
