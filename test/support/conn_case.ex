defmodule UnilinkClient.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      # The default endpoint for testing
      @endpoint UnilinkClient.Endpoint

      def sign_conn(conn, body, query_string, secret) do
        timestamp = :os.system_time(:seconds)
        signature = UnilinkClient.ProtocolSecurity.signature(body, query_string, timestamp, secret)

        conn
        |> put_req_header("authorization", signature)
        |> put_req_header("timestamp", Integer.to_string(timestamp))
        |> put_req_header("content-type", "application/json")
      end

    end
  end


  setup do
    [setting] = UnilinkClient.Config.settings()
    %{setting: setting}
  end

end
