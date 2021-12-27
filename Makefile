export SHELL

SHELLCHECK_OPTS := -s bash -e SC1090
SHELLCHECK_DOCKER_IMAGE := koalaman/shellcheck:stable

TEST_RUNNER := test/support/runner.sh
TEST_FILES := $(wildcard test/*-test.sh)
TEST_DOCKER_BASH_IMAGES := bash!5 bash!4.4 bash!3.2
TEST_DOCKER_ZSH_IMAGES := zshusers/zsh!5.8 zshusers/zsh!5.6.2 zshusers/zsh!5.3

BM_FILES := $(wildcard benchmark/*-bm.sh)

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
lint: SHELL := bash
lint:
	shellcheck $$(< .shellcheck-files)

.PHONY: lint-docker
lint-docker: SHELL := bash
lint-docker:
	docker run \
	    --rm \
	    -t \
	    -v "$(CURDIR):/chnode" \
	    -w /chnode \
	    -e SHELLCHECK_OPTS="$(SHELLCHECK_OPTS)" \
	    $(SHELLCHECK_DOCKER_IMAGE) \
	    $$(< .shellcheck-files)

test/shunit2/shunit2:
	$(git-submodule-reset)

.PHONY: test
test: test/shunit2/shunit2
	$(SHELL) $(TEST_RUNNER) $(TEST_FILES)

.PHONY: test-docker
test-docker: test-docker-bashes test-docker-zshes

.PHONY: test-docker-bashes
test-docker-bashes: $(TEST_DOCKER_BASH_IMAGES)

.PHONY: test-docker-zshes
test-docker-zshes: $(TEST_DOCKER_ZSH_IMAGES)

.PHONY: $(TEST_DOCKER_BASH_IMAGES)
$(TEST_DOCKER_BASH_IMAGES): test/shunit2/shunit2
	docker run \
	    --rm \
	    -t \
	    -v "$(CURDIR):/chnode" \
	    -w /chnode \
	    -e SHELL=/usr/local/bin/bash \
	    $(subst !,:,$@) \
	    bash $(TEST_RUNNER) $(TEST_FILES)

.PHONY: $(DOCKER_TEST_ZSHES)
$(TEST_DOCKER_ZSH_IMAGES): test/shunit2/shunit2
	docker run \
	    --rm \
	    -t \
	    -v "$(CURDIR):/chnode" \
	    -w /chnode \
	    -e SHELL=/usr/bin/zsh \
	    $(subst !,:,$@) \
	    zsh $(TEST_RUNNER) $(TEST_FILES)

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

  lint                Run ShellCheck on source files
  lint-docker         Run ShellCheck on source files in a Docker container

  test                Run tests with SHELL you choose (usage: \`make test SHELL=bash\`) (select: TEST_FILES=test/*-test.sh)
  test-docker         Run tests with various Bash and Zsh versions in Docker containers
  test-docker-bashes  Run tests with various Bash versions in Docker containers
  test-docker-zshes   Run tests with various Zsh versions in Docker containers

  benchmark           Run benchmarks with SHELL you choose (usage: \`make benchmark SHELL=bash\`) (select: BM_FILES=benchmark/*-bm.sh; iterations: N=1000; runs: RUNS=3)

  install             Copy chnode.sh and auto.sh and its documentation to PREFIX directory
  uninstall           Remove chnode.sh and auto.sh and its documentation from PREFIX directory
endef

git-submodule-reset := git submodule init; git submodule update
