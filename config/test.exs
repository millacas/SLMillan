use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sl_millan, SlMillanWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :sl_millan, :sl_api,
  api_key: "api-key",
  api_base_url: "https://someapi.com"
