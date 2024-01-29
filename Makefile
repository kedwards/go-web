mkfile_path:=$(abspath $(dir $(lastword $(MAKEFILE_LIST)))/)
branch_name:=$(shell  git symbolic-ref -q --short HEAD | sed -e "s|^heads/||")
DEFAULT_GOAL:= help

VERSION:=0.0.0
PORT:=8888

##@ [Targets]
help:
	@cat $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}/^##@/{printf "\n\033[1m%s\033[0m\n", substr($$0, 5)}'

build: ## Compile application into binary, make build [ VERSION=<0.0.0> PORT=<8888> ]
	@cd web && \
		go mod tidy && \
		go build -o ../dist/main -ldflags "-X main.version=$(VERSION) -X main.port=$(PORT)" ./cmd/*.go

start: build  ## Starts the application as a native go binary, make start [ VERSION=<0.0.0> PORT=<8888> ]
	@./dist/main & 
 
stop: ## Stops the application
	@pkill -SIGTERM -f "main" &> /dev/null

clean:  ## Cleans older builds and code, make clean
	@rm -f dist/* && \
		go clean

restart: stop start

# docker
cstart: ## Starts the application as container images, make crun [ VERSION=<0.0.0> PORT=<8888> ] 
	@docker build --build-arg VERSION=$(VERSION) --build-arg PORT=$(PORT)  -t go-web:$(VERSION) ./web/ && \
		docker run -itd --rm --name go-web -p $(PORT):$(PORT) go-web:$(VERSION) && \
		docker build --build-arg proxy_host=$$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' go-web) --build-arg port=$(PORT) -t nginx-proxy:$(VERSION) ./nginx-proxy/ && \
	  docker run -itd --rm --name nginx-proxy -p 80:80 nginx-proxy:$(VERSION) && \
		echo 'http://localhost:$(PORT)' && \
		echo 'http://localhost' 

cstop: ## Stop the running containers
	@docker rm -f go-web nginx-proxy

# docker compose
up: ## Build and run via docker-compose, make up [ VERSION=<0.0.0> PORT=<8888> ]
	@sed -i 's|^PORT:.*$$|PORT: $(PORT)|;s|^VERSION:.*$$|VERSION: $(VERSION)|' .env && \
		docker compose up -d --build && \
		echo 'http://localhost:$(PORT)' && \
		echo 'http://localhost' 

down: ## Stop docker compose services
	@docker compose down

guard-%:
	@if [ "${${*}}" = "" ]; then \
		echo "Variable $* not set"; \
		exit 1; \
	fi
