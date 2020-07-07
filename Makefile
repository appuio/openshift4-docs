pages   := $(shell find . -type f -name '*.adoc')
out_dir := ./_archive
web_dir := ./_public

ifeq ($(engine), podman)
	engine_cmd  ?= podman
	engine_opts ?= --rm --tty --user 2001
endif

engine_cmd  ?= docker
engine_opts ?= --rm --tty --user "$$(id -u)"

antora_cmd  ?= $(engine_cmd) run $(engine_opts) --volume "$${PWD}":/antora:Z vshn/antora:2.3.0
antora_opts ?= --cache-dir=.cache/antora

vale_cmd ?= $(engine_cmd) run $(engine_opts) --volume "$${PWD}"/docs/modules:/pages:Z vshn/vale:2.1.1 --minAlertLevel=error /pages

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
all: html open

.PHONY: clean
clean:
	rm -rf $(out_dir) $(web_dir) .cache

.PHONY: open
open: $(web_dir)/index.html
	-$(OPEN) $<

.PHONY: html
html:    $(web_dir)/index.html

$(web_dir)/index.html: playbook.yml $(pages)
	$(antora_cmd) $(antora_opts) $<

.PHONY: check
check:
	$(vale_cmd)

