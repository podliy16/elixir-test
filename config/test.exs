use Mix.Config

# Configure your database
config :awesome_elixir, AwesomeElixir.Repo,
  username: "postgres",
  password: "postgres",
  database: "awesome_elixir_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :awesome_elixir, AwesomeElixirWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :awesome_elixir, retry_sleep: 0
