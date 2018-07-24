defmodule UnilinkClient.Callbacks do
  alias UnilinkClient.Config

  def verify_token(%{params: %{"token" => token}} = conn, _opts) do
    case Phoenix.Token.verify(Config.endpoint, Config.salt, token, max_age: 600) do
      {:ok, id} -> Phoenix.Controller.json(conn, %{valid: true, id: id})
      {:error, error} -> Phoenix.Controller.json(conn, %{valid: false, reason: error})
    end
  end

  def handle_deposit(conn, opts) do
    conn
  end

end
