defmodule UnilinkClient.Uri do
  @moduledoc false
  alias UnilinkClient.Config

  @doc false
  def publish(), do: Config.api_url <> "/api/publish"

  @doc false
  def login(api_key, user_id) when is_binary(api_key) and is_binary(user_id) do
    token = Phoenix.Token.sign(Config.endpoint, Config.salt, user_id)
    "#{Config.api_url}/auth/platform_login?platform=#{api_key}&token=#{token}"
  end

end
