defmodule UnilinkClient.Conn do
  import Plug.Conn
  alias UnilinkClient.ProtocolSecurity

  def json_signed_data(conn, secret, body, status \\ 200) do
    json_body = Poison.encode!(body)

    conn
    |> sign_response(json_body, secret)
    |> send_resp(status, json_body)
  end

  defp sign_response(conn, body, secret) do
    timestamp = :os.system_time(:seconds)
    signature = ProtocolSecurity.signature(body, nil, timestamp, secret)

    conn
    |> put_resp_header("authorization", signature)
    |> put_resp_header("timestamp", Integer.to_string(timestamp))
    |> put_resp_header("content-type", "application/json")
  end

end
