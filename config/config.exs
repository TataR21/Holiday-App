# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :holiday_app,
  ecto_repos: [HolidayApp.Repo]

# Configures the endpoint
config :holiday_app, HolidayAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "wGvJM663AUDgsyllE3EwOpf3i+LCwcd1/engi+F4jgp3ygBukjtJOBK5UOCCF19k",
  render_errors: [view: HolidayAppWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: HolidayApp.PubSub,
  live_view: [signing_salt: "RExafl2e"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :holiday_app, :pow,
  user: HolidayApp.Users.User,
  repo: HolidayApp.Repo,
  web_module: HolidayAppWeb
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
