defmodule UnilinkClient.TestClient do
  use UnilinkClient

  def get_settings, do: %UnilinkClient.Setting{api_key: "api_key", api_secret: "api_secret"}

  def handle_profit(_payout), do: :ok

end

defmodule UnilinkClient.TestClientWithList do
  use UnilinkClient

  def get_settings, do: [%UnilinkClient.Setting{api_key: "api_key", api_secret: "api_secret"}]

  def handle_profit(_payout), do: :ok

end

defmodule UnilinkClient.TestClientWithErrorPayout do

  def get_settings, do: %UnilinkClient.Setting{api_key: "api_key", api_secret: "api_secret"}

  def handle_profit(_payout), do: {:error, :unexpected_error}
  
end
