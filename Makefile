pages   := $(shell find . -type f -name '*.adoc')
out_dir := ./_archive
web_dir := ./_public

ifeq ($(shell command -v podman &> /dev/null; echo $$?),0)
	engine_cmd  ?= podman
	engine_opts ?= --rm --tty --userns=keep-id
else
	engine_cmd  ?= docker
	engine_opts ?= --rm --tty --user "$$(id -u)"
endif

antora_cmd  ?= $(engine_cmd) run $(engine_opts) --volume "$${PWD}":/antora:Z vshn/antora:2.3.0
antora_opts ?= --cache-dir=.cache/antora

vale_cmd ?= $(engine_cmd) run $(engine_opts) --volume "$${PWD}"/docs/modules:/pages:Z vshn/vale:2.1.1 --minAlertLevel=error --config=/pages/ROOT/pages/.vale.ini /pages

UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
	OS = linux-x64
	OPEN = xdg-open
endif
ifeq ($(UNAME), Darwin)
	OS = darwin-x64
	OPEN = open
endif

.PHONY: all
all: docs open

# This will clean the Antora Artifacts, not the npm artifacts
.PHONY: clean
clean:
	rm -rf $(out_dir) $(web_dir) .cache

.PHONY: open
open: $(web_dir)/index.html
	-$(OPEN) $<

.PHONY: docs
docs:    $(web_dir)/index.html

$(web_dir)/index.html: playbook.yml $(pages)
	$(antora_cmd) $(antora_opts) $<

.PHONY: check
check:
	$(vale_cmd)

