export SHELL

SHFMT_OPTS := --diff
SHFMT_DOCKER_IMAGE := mvdan/shfmt:v3-alpine

SHELLCHECK_OPTS := -s bash -e SC1090
SHELLCHECK_DOCKER_IMAGE := koalaman/shellcheck:stable

TEST_RUNNER := test/support/runner.sh
TEST_FILES := $(wildcard test/*-test.sh)
TEST_BASH_DOCKER_IMAGES := bash!5 bash!4 bash!3.2
TEST_ZSH_DOCKER_IMAGES := zshusers/zsh!5.9 zshusers/zsh!5.8 zshusers/zsh!5.6.2 zshusers/zsh!5.3

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

.PHONY: shfmt
shfmt: SHELL := bash
shfmt:
	shfmt $(SHFMT_OPTS) $$(< .sh-files)

.PHONY: shfmt-docker
shfmt-docker: SHELL := bash
shfmt-docker:
	docker run \
	    --rm \
	    -t \
	    -v "$(CURDIR):/chnode:ro" \
	    -w /chnode \
	    $(SHFMT_DOCKER_IMAGE) $(SHFMT_OPTS) \
	    $$(< .sh-files)

.PHONY: shellcheck
shellcheck: SHELL := bash
shellcheck:
	shellcheck $$(< .sh-files)

.PHONY: shellcheck-docker
shellcheck-docker: SHELL := bash
shellcheck-docker:
	docker run \
	    --rm \
	    -t \
	    -v "$(CURDIR):/chnode:ro" \
	    -w /chnode \
	    -e SHELLCHECK_OPTS="$(SHELLCHECK_OPTS)" \
	    $(SHELLCHECK_DOCKER_IMAGE) \
	    $$(< .sh-files)

test/shunit2/shunit2:
	$(git-submodule-reset)

.PHONY: test
test: test/shunit2/shunit2
	$(SHELL) $(TEST_RUNNER) $(TEST_FILES)

.PHONY: test-docker
test-docker: test-bash-docker test-zsh-docker

.PHONY: test-bash-docker
test-bash-docker: $(TEST_BASH_DOCKER_IMAGES)

.PHONY: test-zsh-docker
test-zsh-docker: $(TEST_ZSH_DOCKER_IMAGES)

.PHONY: $(TEST_BASH_DOCKER_IMAGES)
$(TEST_BASH_DOCKER_IMAGES): test/shunit2/shunit2
	docker run \
	    --rm \
	    -t \
	    -v "$(CURDIR):/chnode:ro" \
	    -w /chnode \
	    -e SHELL=/usr/local/bin/bash \
	    $(subst !,:,$@) \
	    bash $(TEST_RUNNER) $(TEST_FILES)

.PHONY: $(TEST_ZSH_DOCKER_IMAGES)
$(TEST_ZSH_DOCKER_IMAGES): test/shunit2/shunit2
	docker run \
	    --rm \
	    -t \
	    -v "$(CURDIR):/chnode:ro" \
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

  help              Show this guide

  shfmt             Run shfmt on source files
  shfmt-docker      Run shfmt on source files in a Docker container

  shellcheck        Run ShellCheck on source files
  shellcheck-docker Run ShellCheck on source files in a Docker container

  test              Run tests with SHELL you choose (usage: \`make test SHELL=bash\`) (select: TEST_FILES=test/*-test.sh)
  test-docker       Run tests with various Bash and Zsh versions in Docker containers
  test-bash-docker  Run tests with various Bash versions in Docker containers
  test-zsh-docker   Run tests with various Zsh versions in Docker containers

  benchmark         Run benchmarks with SHELL you choose (usage: \`make benchmark SHELL=bash\`) (select: BM_FILES=benchmark/*-bm.sh; iterations: N=1000; runs: RUNS=3)

  install           Copy chnode.sh and auto.sh and its documentation to PREFIX directory
  uninstall         Remove chnode.sh and auto.sh and its documentation from PREFIX directory
endef

git-submodule-reset := git submodule init; git submodule update
