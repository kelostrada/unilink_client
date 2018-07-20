defmodule UnilinkClient.TestClient do
  use UnilinkClient

  def get_settings, do: %UnilinkClient.Setting{api_key: "api_key", api_secret: "api_secret"}

end

defmodule UnilinkClient.TestClientWithList do
  use UnilinkClient

  def get_settings, do: [%UnilinkClient.Setting{api_key: "api_key", api_secret: "api_secret"}]

end
