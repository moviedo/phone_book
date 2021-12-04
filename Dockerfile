FROM elixir:1.12-alpine
ENV DEBIAN_FRONTEND=noninteractive

# Install hex
RUN mix local.hex --force

# Install rebar
RUN mix local.rebar --force

# Install the Phoenix framework itself
RUN mix archive.install hex phx_new --force

# https://hexdocs.pm/phoenix/installation.html#inotify-tools-for-linux-users
RUN apk update && apk add inotify-tools \
    inotify-tools \
    && rm -rf /var/lib/apt/lists/*

RUN apk add git build-base

# When this image is run, make /app the current working directory
WORKDIR /app