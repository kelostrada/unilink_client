use Mix.Config

# Configures the endpoint
config :unilink_client, UnilinkClient.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nhXyaUP7Vs1PUZquWiRkYoANWRH/heAAGidOTK1Ox1VmL16HCnw2rDb6MptXjlsU"

config :unilink_client,
  module: UnilinkClient.TestClient,
  endpoint: UnilinkClient.Endpoint,
  event_sources: [],
  api_url: "https://api.unilink.io",
  debug_token_path: "/unilink/debug_token",
  receive_profit_path: "/unilink/receive_profit"

# Do not print logs in tests
config :logger, level: :warn
