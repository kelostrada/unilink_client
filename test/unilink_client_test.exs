defmodule UnilinkClientTest do
  use ExUnit.Case
  alias UnilinkClient.Config

  test "gets login url" do
    "https://api.unilink.io/auth/platform_login?platform=api_key&token=" <> token
      = UnilinkClient.get_login_url("api_key", "1")

    {:ok, "1"} = Phoenix.Token.verify(Config.endpoint, Config.salt, token, max_age: 100)
  end

  test "gets api_secret by api_key" do
    assert {:ok, "api_secret"} == UnilinkClient.get_secret("api_key")
  end

end
