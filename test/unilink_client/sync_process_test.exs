defmodule UnilinkClient.SyncProcessTest do
  use ExUnit.Case, async: false
  import Mock
  alias UnilinkClient.{Process, TestEventsSource, TestEventsSourceFull, ApiClient}

  import UnilinkClient.TestEventsSource.Mocks

  setup do
    setting = UnilinkClient.TestClient.get_settings()
    %{setting: setting}
  end

  test "process should fetch events from source, send to api, mark as sent, and schedule next batch", %{setting: setting} do
    with_mocks([
      full_batch_source_mock(TestEventsSource),
      {
        ApiClient, [], [
          send_batch: fn(_events, _api_key, _api_secret) ->
            (10..15 |> Enum.map(&(%{"id" => Integer.to_string(&1), "success" => true})))
            ++
            (1..9 |> Enum.map(&(%{"id" => Integer.to_string(&1), "success" => false})))
          end
        ]
      }
    ])
    do
      Process.next_state([TestEventsSource], 20, setting)

      assert called TestEventsSource.get(20, setting)
      assert called ApiClient.send_batch(events(20), setting.api_key, setting.api_secret)
      assert called TestEventsSource.mark_as_sent(10..15 |> Enum.map(&(Integer.to_string(&1))))
    end
  end

  test "next batch schould be scheduled", %{setting: setting} do
    with_mocks([
      half_batch_source_mock(TestEventsSource),
      full_batch_source_mock(TestEventsSourceFull),
      api_client_mock()
    ])
    do
      assert Process.next_state([TestEventsSource], 10, setting) == :schedule_lazy

      assert Process.next_state([TestEventsSourceFull], 10, setting) == :schedule_fast

      assert Process.next_state([TestEventsSource, TestEventsSourceFull], 10, setting) == :schedule_fast
    end
  end

  test "next source batch should be send if previous wasn't full", %{setting: setting} do
    with_mocks([
      half_batch_source_mock(TestEventsSource),
      full_batch_source_mock(TestEventsSourceFull),
      api_client_mock()
    ])
    do
      # TestEventsSource have only half of max batch size - we can start sync next source
      Process.next_state([TestEventsSource, TestEventsSourceFull], 10, setting)
      assert called TestEventsSource.get(10, setting)
      assert called ApiClient.send_batch(events(5), setting.api_key, setting.api_secret)

      assert called TestEventsSourceFull.get(10, setting)
      assert called ApiClient.send_batch(events(10), setting.api_key, setting.api_secret)
    end
  end

  test "source with full batch should be sync first", %{setting: setting} do
    with_mocks([
      half_batch_source_mock(TestEventsSource),
      full_batch_source_mock(TestEventsSourceFull),
      api_client_mock()
    ])
    do
      # TestEventsSourceFull have full batch, so we cannot start syncing next batch
      Process.next_state([TestEventsSourceFull, TestEventsSource], 10, setting)
      assert called TestEventsSourceFull.get(10, setting)
      assert called ApiClient.send_batch(events(10), setting.api_key, setting.api_secret)

      refute called TestEventsSource.get(10, setting)
      refute called ApiClient.send_batch(events(5))
    end
  end

end
