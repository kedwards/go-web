mkfile_path:=$(abspath $(dir $(lastword $(MAKEFILE_LIST)))/)
branch_name:=$(shell  git symbolic-ref -q --short HEAD | sed -e "s|^heads/||")
DEFAULT_GOAL:= help

VERSION:=X.X.X

ifneq ($(SERVICE),)
	SERVICE_ARG="--build-arg service=$(SERVICE)"
endif

ifneq ($(PORT),)
	PORT_ARG="--build-arg port=$(PORT)"
endif

##@ [Targets]
help:
	@cat $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}/^##@/{printf "\n\033[1m%s\033[0m\n", substr($$0, 5)}'

guard-%:
	@if [ "${${*}}" = "" ]; then \
 		echo "Variable $* not set"; \
  		exit 1; \
  	fi

build:  ## Build docker image, make build [ SERVICE=<go-rest-app> PORT=<8888> VERSION=<X.X.X> ]
	@docker build "$(SERVICE_ARG)" "$(PORT_ARG)" -t nginx-proxy:$(VERSION) .
