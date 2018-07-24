defmodule UnilinkClient.Plug.VerifySignature do
  require Logger
  import Plug.Conn
  alias UnilinkClient.ProtocolSecurity

  @max_allowed_clock_skew 5

  def verify_signature(%{params: %{"api_key" => api_key}, query_string: query_string} = conn, _) do
    with {:ok, api_secret} <- UnilinkClient.get_secret(api_key),
      [signature] <- get_req_header(conn, "authorization"),
      [timestamp] <- get_req_header(conn, "timestamp"),
      :ok <- ProtocolSecurity.check_signature(conn.private[:raw_body], query_string, timestamp, api_secret, signature, @max_allowed_clock_skew) do
        Logger.debug "Request signature verified"
        conn
    else
      {:error, reason} ->
        Logger.info "Request signature verification failed with #{inspect reason}, sending Unauthorized"
        conn
        |> send_resp(401, "Unauthorized")
        |> halt
      _ ->
        Logger.info "Required Authorization data not present, sending Unauthorized"
        conn
        |> send_resp(401, "Unauthorized")
        |> halt
    end
  end
  def verify_signature(conn, _) do
    Logger.info "Required Authorization data not present, sending Unauthorized"
    conn
    |> send_resp(401, "Unauthorized")
    |> halt
  end

end
