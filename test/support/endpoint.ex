defmodule UnilinkClient.Endpoint do
  use Phoenix.Endpoint, otp_app: :unilink_client

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    body_reader: {RawBodyReader, :read_body, []},
    pass: ["*/*"],
    json_decoder: Jason

  plug UnilinkClient.Plug

end
