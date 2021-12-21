# Phone Book

## Pre-requistes
Install [make](https://formulae.brew.sh/formula/make#default) and [docker desktop](https://www.docker.com/products/docker-desktop).

Optional instructions to install make 3.82
  1. Install through [brew](https://brew.sh/)
  1. Install make, `brew install make`

## Setup
To start your Phoenix server run the command `make start` and you can optionally seed the database with `make seed` (check priv/repo/seeds.exs file for data).

This commands runs the following:
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Run `make stop` to stop the docker containers and your application.

Run `make help` for all available command options.

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## Helpful Commands

Run commands on the container.
```
docker-compose exec web <command>
```

Example: Enter shell in container
```
docker-compose exec web sh
```

## Commit Convention Rules

Structure of commit messages
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Example commit message: 

| Commit message                                                                                                                                                                                   | Release type               |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------- |
| `fix(pencil): stop graphite breaking when too much pressure applied`                                                                                                                             | Patch Release              |
| `feat(pencil): add 'graphiteWidth' option`                                                                                                                                                       | Feature Release  |
| `perf(pencil): remove graphiteWidth option`<br><br>`BREAKING CHANGE: The graphiteWidth option has been removed.`<br>`The default graphite width of 10mm is always used for performance reasons.` | Breaking Release |
| `perf!: remove graphiteWidth option` | Breaking Release |
| `perf(pencil)!: remove graphiteWidth option` | Breaking Release |

### Major, Minor, Patch 

The commit contains the following structural elements, to communicate intent to the consumers of your library:

1. fix: a commit of the type fix patches a bug in your codebase (this correlates with PATCH in Semantic Versioning).
1. feat: a commit of the type feat introduces a new feature to the codebase (this correlates with MINOR in Semantic Versioning).
1. BREAKING CHANGE: a commit that has a footer BREAKING CHANGE:, or appends a ! after the type/scope, introduces a breaking API change (correlating with MAJOR in Semantic Versioning).

### Types

Commit messages must be one of the following:

    build: Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
    chore: updating grunt tasks, version release etc; no production code change
    ci: Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
    docs: Documentation only changes
    feat: A new feature
    fix: A bug fix
    perf: A code change that improves performance
    refactor: A code change that neither fixes a bug nor adds a feature
    style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
    test: Adding missing tests or correcting existing tests

Reference:
1. [conventional commit config](https://hexdocs.pm/git_ops/readme.html#configuration)
1. [vuejs integration](https://dev.to/mcraealex/setting-up-vue-and-phoenix-1-5-with-vue-cli-488c)