defmodule UnilinkClient.PlugTest do
  use UnilinkClient.ConnCase

  alias UnilinkClient.Config

  test "debugs token", %{setting: setting} do
    token = Phoenix.Token.sign(Config.endpoint, Config.salt, "1")

    query_string = "api_key=" <> setting.api_key
    url = "/unilink/debug_token" <> "?" <> query_string
    body = Jason.encode!(%{token: token})

    expires_at = 86400 + :os.system_time(:seconds) |> Integer.to_string

    conn =
      build_conn(:post, url, body)
      |> sign_conn(body, query_string, setting.api_secret)
      |> @endpoint.call([])

    assert %{"id" => "1", "valid" => true, "expires" => expires_at} == json_response(conn, 200)
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

  test "accepts profit", %{setting: setting} do
    query_string = "api_key=" <> setting.api_key
    url = "/unilink/receive_profit" <> "?" <> query_string
    body = Jason.encode!(%{id: "1", user_id: "1", amount: "123.5", timestamp: 123123123})

    conn =
      build_conn(:post, url, body)
      |> sign_conn(body, query_string, setting.api_secret)
      |> @endpoint.call([])

    assert json_response(conn, 202)
  end

  test "rejects profit", %{setting: setting} do
    module = Application.get_env(:unilink_client, :module)
    Application.put_env(:unilink_client, :module, UnilinkClient.TestClientWithErrorPayout)

    query_string = "api_key=" <> setting.api_key
    url = "/unilink/receive_profit" <> "?" <> query_string
    body = Jason.encode!(%{id: "1", user_id: "1", amount: "123.523", timestamp: 123123123})

    conn =
      build_conn(:post, url, body)
      |> sign_conn(body, query_string, setting.api_secret)
      |> @endpoint.call([])

    assert json_response(conn, 403)

    Application.put_env(:unilink_client, :module, module)
  end

  test "ignores all other requests" do
    query_string = "api_key=123123"
    url = "/unilink/test" <> "?" <> query_string
    body = Jason.encode!(%{id: "1", user_id: "1", amount: "123.523", timestamp: 123123123})

    conn =
      build_conn(:post, url, body)
      |> @endpoint.call([])

    assert conn.status == nil
    assert conn.state == :unset
    assert conn.halted == false
  end

  test "doesn't verify signature in receive_profit" do
    url = "/unilink/receive_profit"
    body = Jason.encode!(%{id: "1", user_id: "1", amount: "123.5", timestamp: 123123123})

    conn =
      build_conn(:post, url, body)
      |> @endpoint.call([])

    assert response(conn, 401)
  end

  test "doesn't verify signature in debug_token" do
    url = "/unilink/debug_token"
    body = Jason.encode!(%{token: "token"})

    conn =
      build_conn(:post, url, body)
      |> @endpoint.call([])

    assert response(conn, 401)
  end

end
