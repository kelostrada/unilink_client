defmodule RawBodyReader do

  def read_body(conn, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
    conn = update_in(conn.private[:raw_body], fn _ -> body end)
    {:ok, body, conn}
  end

end
