use Mix.Config

config :unilink_client,
  module: UnilinkClient.TestClient,
  event_sources: [],
  api_url: "https://api.unilink.io/api/publish",
  login_url: "https://api.unilink.io/auth/platform_login?platform=[API_KEY]&token="

# Do not print logs in tests
config :logger, level: :warn
