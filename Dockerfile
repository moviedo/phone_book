FROM elixir:1.13-alpine

# Install hex
RUN mix local.hex --force && \
    # Install rebar
    mix local.rebar --force && \ 
    # Install the Phoenix framework itself
    mix archive.install hex phx_new --force 

# https://hexdocs.pm/phoenix/installation.html#inotify-tools-for-linux-users
RUN apk update && apk add inotify-tools \
    inotify-tools \
    git \
    build-base \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# When this image is run, make /app the current working directory
WORKDIR /app