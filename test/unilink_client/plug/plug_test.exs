defmodule UnilinkClient.PlugTest do
  use ExUnit.Case

  use Phoenix.ConnTest
  @endpoint UnilinkClient.Endpoint

  # alias UnilinkClient.Plug

  setup do
    conn = Phoenix.ConnTest.build_conn()
    %{conn: conn}
  end

  test "debugs token", %{conn: conn} do
    conn = post conn, "/unilink/debug_token", lol: %{a: 1}
    IO.inspect json_response(conn, 200)


  end


end
