import Config

# Configure your database
config :phone_book, PhoneBook.Repo,
  url: "ecto://postgres:postgres@db/phone_book_dev",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :phone_book, PhoneBookWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "DUhb+FERO8UANybZ1lG3jFJtFH7sulBITi/XjYFly/qNbqTudFBSYXa+psp5z+mb",
  watchers: [
    # Start the esbuild watcher by calling Esbuild.install_and_run(:default, args)
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--watch",
      "--mode",
      "development",
      "--watch-options-stdin",
      "--config",
      "node_modules/@vue/cli-service/webpack.config.js",
      cd: Path.expand("../vue_app", __DIR__)
    ]
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :phone_book, PhoneBookWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/phone_book_web/(live|views)/.*(ex)$",
      ~r"lib/phone_book_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# githooks configuration
config :git_hooks,
  auto_install: true,
  verbose: true,
  mix_path: "docker exec --tty $(docker-compose ps -q web) mix",
  hooks: [
    commit_msg: [
      tasks: [
        {:cmd, "mix git_ops.check_message", include_hook_args: true}
      ]
    ],
    pre_commit: [
      tasks: [
        {:file, "./priv/githooks/pre_commit.sh"}
      ]
    ]
  ]

# Conventional commit tool configuration
config :git_ops,
  mix_project: Mix.Project.get!(),
  changelog_file: "CHANGELOG.md",
  repository_url: "https://github.com/moviedo/phone-book",
  types: [
    build: [
      hidden?: true
    ],
    chore: [
      hidden?: true
    ],
    ci: [
      hidden?: true
    ],
    docs: [
      hidden?: true
    ],
    feat: [
      header: "Features",
      hidden?: false
    ],
    fix: [
      header: "Bug Fixes",
      hidden?: false
    ],
    improvement: [
      header: "Improvements",
      hidden?: false
    ],
    perf: [
      header: "Performance Improvements",
      hidden?: false
    ],
    refactor: [
      hidden?: true
    ],
    style: [
      hidden?: true
    ],
    test: [
      hidden?: true
    ]
  ],
  manage_mix_version?: true,
  version_tag_prefix: "v"
