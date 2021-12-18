##
##  DEPENDENCIES
## ================
## * UNIX operating system
## * GNU Make >= 4.3
## * GNU Bash >= 3.2.57

## -- Phoenix Targets --

## install phoenix package dependencies
install_deps: 
	@docker run \
	-v "/$$(pwd)":/app \
	-w /app \
	elixir:1.13-alpine \
	sh -c "mix local.hex --force && mix deps.get"

## Checks linting on elixir files with formatter
lint: 
	@docker-compose exec web mix format --check-formatted && docker-compose exec web mix credo --strict

## Lints the project and replaces in place the linted files.
lint_fix:
	@docker-compose exec web mix format

## run application automated tests
mix_test:
	@docker-compose exec --env MIX_ENV=test web mix test

## create new phoenix project: make new_project APP=example
new_project: 
	@docker run \
	-v "/$$(pwd)":/app \
	-w /app \
	elixir:1.13-alpine \
	sh -c "mix local.hex --force && mix archive.install hex phx_new --force && mix phx.new ${APP} --install --binary-id"

## project release and tag using conventional commit
release:
	@docker-compose run web mix git_ops.release

## restart web container so phoenix server can rebuild/restart
restart:
	@docker-compose restart web

## start docker-compose containers
start_docker:
	@docker-compose down && \
	docker-compose run web mix ecto.setup && \
	docker-compose -f docker-compose.yml up -d --remove-orphans 

## start development environment with docker-compose
start: 
	- @make install_deps
	make start_docker

## stop development environment with docker-compose
stop: 
	@docker-compose down

# Credit: https://gist.github.com/prwhite/8168133#gistcomment-2749866
help:
	@printf "Usage\n";

	@awk '{ \
			if ($$0 ~ /^.PHONY: [a-zA-Z\-\_0-9]+$$/) { \
				helpCommand = substr($$0, index($$0, ":") + 2); \
				if (helpMessage) { \
					printf "\033[36m%-20s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^[a-zA-Z\-\_0-9.]+:/) { \
				helpCommand = substr($$0, 0, index($$0, ":")); \
				if (helpMessage) { \
					printf "\033[36m%-20s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^##/) { \
				if (helpMessage) { \
					helpMessage = helpMessage"\n                     "substr($$0, 3); \
				} else { \
					helpMessage = substr($$0, 3); \
				} \
			} else { \
				if (helpMessage) { \
					print "\n                     "helpMessage"\n" \
				} \
				helpMessage = ""; \
			} \
		}' \
		$(MAKEFILE_LIST)