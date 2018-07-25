defmodule UnilinkClient.Config do

  def active?, do: !Application.get_env(:unilink_client, :inactive, false)

  def api_url, do: Application.get_env(:unilink_client, :api_url, "https://api.unilink.io")

  def debug_token_path, do: Application.get_env(:unilink_client, :debug_token_path, "/unilink/debug_token")

  def event_sources, do: Application.fetch_env!(:unilink_client, :event_sources)

  def endpoint, do: Application.fetch_env!(:unilink_client, :endpoint)

  def module, do: Application.fetch_env!(:unilink_client, :module)

  def receive_profit_path, do: Application.get_env(:unilink_client, :receive_profit_path, "/unilink/receive_profit")

  def salt, do: Application.get_env(:unilink_client, :salt, "token salt")

  def token_duration, do: Application.get_env(:unilink_client, :token_duration, 86400)

  def settings do
    module().get_settings()
    |> wrap_with_list()
  end

  defp wrap_with_list(list) when is_list(list), do: list
  defp wrap_with_list(elem), do: [elem]

end
