defmodule UnilinkClient.TestEventsSource do
  @behaviour UnilinkClient.EventsSource

  def get(_batch_size, _setting), do: []

  def mark_as_sent(_event_ids), do: :ok
end

defmodule UnilinkClient.TestEventsSourceFull do
  @behaviour UnilinkClient.EventsSource

  def get(_batch_size, _setting), do: []

  def mark_as_sent(_event_ids), do: :ok
end


defmodule UnilinkClient.TestEventsSource.Mocks do
  alias UnilinkClient.ApiClient
  alias UnilinkClient.Events.GenericEvent

  def full_batch_source_mock(module) do
    {
      module,
      [],
      [
        get: fn(batch_size, _) -> events(batch_size) end,
        mark_as_sent: fn (_) -> :ok end
      ]
    }
  end

  def half_batch_source_mock(module) do
    {
      module,
      [],
      [
        get: fn(batch_size, _) -> div(batch_size, 2) |> events() end,
        mark_as_sent: fn (_) -> :ok end
      ]
    }
  end

  def api_client_mock() do
    {
      ApiClient,
      [],
      [
        send_batch: fn(_events, _api_key, _api_secret) -> [] end
      ]
    }
  end

  def events(batch_size) do
    1..batch_size |> Enum.map(fn x -> %GenericEvent{event_id: x |> Integer.to_string()} end)
  end

end
