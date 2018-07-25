defmodule UnilinkClient.Callbacks do
  alias UnilinkClient.Config
  import UnilinkClient.Conn

  def verify_token(%{halted: true} = conn, _opts), do: conn
  def verify_token(%{params: %{"token" => token, "api_key" => api_key}} = conn, _opts) do
    {:ok, api_secret} = UnilinkClient.get_secret(api_key)
    case Phoenix.Token.verify(Config.endpoint, Config.salt, token, max_age: 600) do
      {:ok, id} ->
        expires_at = Config.token_duration + :os.system_time(:seconds) |> Integer.to_string
        json_signed_data(conn, api_secret, %{valid: true, id: id, expires: expires_at})
      {:error, error} -> json_signed_data(conn, api_secret, %{valid: false, reason: error})
    end
  end

  def handle_profit(%{halted: true} = conn, _opts), do: conn
  def handle_profit(%{params: %{"api_key" => api_key} = params} = conn, _opts) do
    profit = UnilinkClient.Payout.format(params)
    {:ok, api_secret} = UnilinkClient.get_secret(api_key)
    case Config.module.handle_profit(profit) do
      :ok -> json_signed_data(conn, api_secret, %{result: :success}, 202)
      {:error, error} -> json_signed_data(conn, api_secret, %{error: error}, 403)
    end
  end

end
