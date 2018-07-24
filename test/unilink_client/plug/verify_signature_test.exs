defmodule UnilinkClient.Plug.VerifySignatureTest do
  use UnilinkClient.ConnCase
  alias UnilinkClient.Plug.VerifySignature
  import Plug.Conn

  test "Signed message should pass signature verification", %{setting: setting} do
    query_string = "api_key=" <> setting.api_key
    url = "url" <> "?" <> query_string
    body = "body"

    conn =
      build_conn(:post, url, body)
      |> put_private(:raw_body, body)
      |> sign_conn(body, query_string, setting.api_secret)
      |> fetch_query_params()
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
      |> fetch_query_params()
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
      |> fetch_query_params()
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
      |> fetch_query_params()
      |> VerifySignature.verify_signature(%{})

    assert conn.status == 401
    assert conn.state == :sent
    assert conn.halted == true
  end

end
