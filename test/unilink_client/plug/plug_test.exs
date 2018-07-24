defmodule UnilinkClient.PlugTest do
  use UnilinkClient.ConnCase

  alias UnilinkClient.Config

  test "debugs token", %{setting: setting} do
    token = Phoenix.Token.sign(Config.endpoint, Config.salt, "1")

    query_string = "api_key=" <> setting.api_key
    url = "/unilink/debug_token" <> "?" <> query_string
    body = Jason.encode!(%{token: token})

    conn =
      build_conn(:post, url, body)
      |> sign_conn(body, query_string, setting.api_secret)
      |> @endpoint.call([])

    assert %{"id" => "1", "valid" => true} == json_response(conn, 200)
  end

  test "fails to debug token", %{setting: setting} do

    query_string = "api_key=" <> setting.api_key
    url = "/unilink/debug_token" <> "?" <> query_string
    body = Jason.encode!(%{token: "invalid token"})

    conn =
      build_conn(:post, url, body)
      |> sign_conn(body, query_string, setting.api_secret)
      |> @endpoint.call([])

    assert %{"valid" => false, "reason" => "invalid"} == json_response(conn, 200)
  end

end
