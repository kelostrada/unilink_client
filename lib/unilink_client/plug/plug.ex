defmodule UnilinkClient.Plug do
  import UnilinkClient.Plug.VerifySignature
  import UnilinkClient.Callbacks
  import Plug.Conn

  alias UnilinkClient.Config

  def init(opts \\ %{}), do: Enum.into(opts, %{})

  def call(conn, opts) do
    debug_token_path = Config.debug_token_path()
    receive_profit_path = Config.receive_profit_path()

    case conn.request_path do
      ^debug_token_path ->
        conn
        |> verify_signature(opts)
        |> verify_token(opts)
        |> halt
      ^receive_profit_path ->
        conn
        |> verify_signature(opts)
        |> handle_profit(opts)
        |> halt
      _ ->
        conn
    end
  end

end
