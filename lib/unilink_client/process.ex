defmodule UnilinkClient.Process do
  alias UnilinkClient.{Setting, ApiClient}

  def next_state(event_sources, batch_size, %Setting{} = setting) do
    next_source(event_sources, batch_size, setting)
  end

  defp next_source([] = _sources, _batch_size, %Setting{} = _setting), do: :schedule_lazy
  defp next_source([curr_source | t] = _sources, batch_size, %Setting{api_key: api_key, api_secret: api_secret} = setting) do
    events = curr_source.get(batch_size, setting)

    if events != [] && api_key && api_secret do
      events
      |> ApiClient.send_batch(api_key, api_secret)
      |> get_synced_event_ids()
      |> curr_source.mark_as_sent()
    end

    if Enum.count(events) == batch_size do
      :schedule_fast
    else
      next_source(t, batch_size, setting)
    end
  end

  def get_synced_event_ids(publish_result) when is_list(publish_result) do
    publish_result
    |> Enum.filter(&(match?(%{"success" => true}, &1)))
    |> Enum.map(&(&1["id"]))
  end
end
