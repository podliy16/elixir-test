# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :awesome_elixir,
  ecto_repos: [AwesomeElixir.Repo]

# Configures the endpoint
config :awesome_elixir, AwesomeElixirWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "LDgq0cVsW/We630tyOxwvNvGU90zElRU8c0oCg4UTdUSKufLP4I/3Ggv7VpgpRJs",
  render_errors: [view: AwesomeElixirWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AwesomeElixir.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

github_token = System.get_env("GITHUB_TOKEN") || ""
config :awesome_elixir, github_token: github_token

config :awesome_elixir, retry_sleep: 30_000

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
