defmodule UnilinkClient.ApiClientTest do
  use ExUnit.Case, async: false
  alias UnilinkClient.ApiClient

  import Mock
  import UnilinkClient.TestEventsSource.Mocks

  test "send one event" do
    with_mocks([
      {
        UnilinkClient.ProtocolSecurity,
        [],
        [
          signature: fn(_, _, _, _) -> "11111111111111111111" end,
          check_signature: fn(_, _, _, _, _, _) -> :ok end
        ]
      },
      {
        HTTPoison,
        [],
        [
          post!: fn(_, _, _) -> %HTTPoison.Response{
            status_code: 202,
            body: "{\"id\": 1, \"success\": true}"
          } end
        ]
      }
    ])
    do
      assert %{"id" => 1, "success" => true} == ApiClient.send_batch(events(1), "key", "secret")
    end
  end

end
