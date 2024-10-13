mkfile_path := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/)

branch_name := $(shell git rev-parse --abbrev-ref HEAD)
tag_or_branch_name := $(shell git describe --tags --abbrev=0 2>/dev/null || echo $(branch_name))

VERSION ?= $(tag_or_branch_name)
PORT ?= 8888
COLOR ?= 000000
DEFAULT_GOAL:= help

##@ [Targets]
help:
	@cat $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}/^##@/{printf "\n\033[1m%s\033[0m\n", substr($$0, 5)}'

# native go
build: ## Compile application into binary, make build [ VERSION=<branch|tag> PORT=<8888> COLOR=<000000> ]
	@cd web && \
		go mod tidy && \
		go build -o ../dist/main -ldflags "-X main.version=$(VERSION) -X main.port=$(PORT) -X main.color=$(COLOR)" ./cmd/*.go

run: build  ## Starts the application as a native go binary, make run <build-envs>
	@./dist/main & 
 
stop: ## Stops the application, make stop
	@pkill -SIGTERM -f "main" &> /dev/null

clean:  ## Cleans older builds and code, make clean
	@rm -f dist/* && \
		go clean

# docker
cbuild: ## Build the application as container image, make cbuild <build-envs>
	@docker build --build-arg VERSION=$(VERSION) --build-arg PORT=$(PORT)  -t go-web:$(VERSION) ./web/

crun: cbuild ## Run the application as container images, make crun <build-envs>
	@docker run -itd --rm --name go-web -p $(PORT):$(PORT) go-web:$(VERSION) && \
		echo 'http://localhost:$(PORT)'

cprun: crun ## Run the application as container image with apache proxy, make crun <build-envs> 
	@docker build --build-arg proxy_host=$$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' go-web) --build-arg port=$(PORT) -t nginx-proxy:$(VERSION) ./nginx-proxy/ && \
	  docker run -itd --rm --name nginx-proxy -p 80:80 nginx-proxy:$(VERSION) && \
		echo 'http://localhost' 

cstop: ## Stop the running containers, make cstop
	@docker rm -f go-web nginx-proxy

# docker compose
up: ## Build and run via docker-compose, make up <build-envs>
	@sed -i 's|^PORT:.*$$|PORT: $(PORT)|;s|^VERSION:.*$$|VERSION: $(VERSION)|;s|^COLOR:.*$$|COLOR: $(COLOR)|' .env && \
		docker compose up -d --build && \
		echo 'http://localhost:$(PORT)' && \
		echo 'http://localhost' 

down: ## Stop docker compose services, make down
	@docker compose down

guard-%:
	@if [ "${${*}}" = "" ]; then \
		echo "Variable $* not set"; \
		exit 1; \
	fi
