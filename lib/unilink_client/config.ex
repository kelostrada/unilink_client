defmodule UnilinkClient.Config do

  def module, do: Application.fetch_env!(:unilink_client, :module)

  def active?, do: !Application.get_env(:unilink_client, :inactive, false)

  def api_url, do: Application.fetch_env!(:unilink_client, :api_url)

  def login_url, do: Application.fetch_env!(:unilink_client, :login_url)

  def event_sources, do: Application.fetch_env!(:unilink_client, :event_sources)

  def settings do
    module().get_settings()
    |> wrap_with_list()
  end

  defp wrap_with_list(list) when is_list(list), do: list
  defp wrap_with_list(elem), do: [elem]

end
