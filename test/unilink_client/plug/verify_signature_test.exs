defmodule UnilinkClient.Plug.VerifySignatureTest do
  use ExUnit.Case
  alias UnilinkClient.{Config, ProtocolSecurity, Plug.VerifySignature}
  import Plug.Conn

  defp build_conn(method, url, body \\ nil) do
    %Plug.Conn{}
    |> Plug.Adapters.Test.Conn.conn(method, url, body)
    |> fetch_query_params()
  end

  setup do
    conn = build_conn(:get, "/")
    [setting] = Config.settings()
    %{conn: conn, setting: setting}
  end

  test "Signed message should pass signature verification", %{setting: setting} do
    query_string = "api_key=" <> setting.api_key
    url = "url" <> "?" <> query_string
    body = "body"

    conn =
      build_conn(:post, url, body)
      |> put_private(:raw_body, body)
      |> sign_conn(body, query_string, setting.api_secret)
      |> VerifySignature.verify_signature(%{})

    assert conn.status == nil
    assert conn.state == :unset
    assert conn.halted == false
  end

  test "Message with wrong query string signature should be unauthorized", %{setting: setting} do
    query_string = "api_key=" <> setting.api_key
    url = "url" <> "?" <> query_string
    body = "body"

    conn =
      build_conn(:post, url, body)
      |> put_private(:raw_body, body)
      |> sign_conn(body, "wrong_query_string", setting.api_secret)
      |> VerifySignature.verify_signature(%{})

    assert conn.status == 401
    assert conn.state == :sent
    assert conn.halted == true
  end

  test "Message with wrong body signature should be unauthorized", %{setting: setting} do
    query_string = "api_key=" <> setting.api_key
    url = "url" <> "?" <> query_string
    body = "body"

    conn =
      build_conn(:post, url, "wrong_body")
      |> put_private(:raw_body, body)
      |> sign_conn("wrong_body", query_string, setting.api_secret)
      |> VerifySignature.verify_signature(%{})

    assert conn.status == 401
    assert conn.state == :sent
    assert conn.halted == true
  end

  test "Message with missing signature headers should be unauthorized", %{setting: setting} do
    query_string = "api_key=" <> setting.api_key
    url = "url" <> "?" <> query_string
    body = "body"

    conn =
      build_conn(:post, url, body)
      |> put_private(:raw_body, body)
      |> VerifySignature.verify_signature(%{})

    assert conn.status == 401
    assert conn.state == :sent
    assert conn.halted == true
  end

  # PRIVATE

  defp sign_conn(conn, body, query_string, secret) do
    timestamp = :os.system_time(:seconds)
    signature = ProtocolSecurity.signature(body, query_string, timestamp, secret)

    conn
    |> put_req_header("authorization", signature)
    |> put_req_header("timestamp", Integer.to_string(timestamp))
    |> put_req_header("content-type", "application/json")
  end
end
