defmodule UnilinkClient.Callbacks do
  alias UnilinkClient.Config
  import Phoenix.Controller

  def verify_token(%{params: %{"token" => token}} = conn, _opts) do
    case Phoenix.Token.verify(Config.endpoint, Config.salt, token, max_age: 600) do
      {:ok, id} -> json(conn, %{valid: true, id: id})
      {:error, error} -> json(conn, %{valid: false, reason: error})
    end
  end

  def handle_profit(%{params: params} = conn, _opts) do
    profit = UnilinkClient.Payout.format(params)
    case Config.module.handle_profit(profit) do
      :ok ->
        conn
        |> Plug.Conn.put_status(202)
        |> json(%{result: :success})
      {:error, error} ->
        conn
        |> Plug.Conn.put_status(403)
        |> json(%{error: error})
    end
  end

end
