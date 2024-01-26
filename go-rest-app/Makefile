mkfile_path:=$(abspath $(dir $(lastword $(MAKEFILE_LIST)))/)
branch_name:=$(shell  git symbolic-ref -q --short HEAD | sed -e "s|^heads/||")
DEFAULT_GOAL:= help

VERSION:=X.X.X

##@ [Targets]
help:
	@cat $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}/^##@/{printf "\n\033[1m%s\033[0m\n", substr($$0, 5)}'

build: ## Compile application into binary
	@go mod tidy && \
		go build -o dist/main ./cmd/web/*.go

clean:  ## Cleans all binaries and runs go clean
	@rm -f dist/*
	@go clean

start: build  ## Starts the application 
	@./dist/main &

stop: ## Stops the application
	@pkill -SIGTERM -f "main" &> /dev/null

dbuild: ## Build docker image, make dbuild [ VERSION=<version> ]
	@docker build --build-arg VERSION=$(VERSION) -t go-rest:$(VERSION) .

drun: dbuild  ## Runs the application in a docker container, creates it if it does not exist
	@docker run -itd --name go-rest -p 80:8888 go-rest:$(VERSION)

dstop:  ## Stop the docker container
	@docker rm -f qp-web

# Restarts the application
restart: stop start
