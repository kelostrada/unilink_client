defmodule UnilinkClient.ApiClient do
  require Logger
  alias UnilinkClient.{Config, ProtocolSecurity}

  @max_allowed_clock_skew 5

  def send_batch([], _api_key, _api_secret), do: []
  def send_batch(events, api_key, api_secret) do

    timestamp = :os.system_time(:seconds) |> Integer.to_string
    body = %{events: events, api_key: api_key}

    Logger.info("Sending Unilink events batch: #{inspect body}")

    payload = Poison.encode!(body)
    signature = ProtocolSecurity.signature(payload, nil, timestamp, api_secret)

    response = send_request!(Config.api_url, payload, signature, timestamp)
    Logger.info("Unilink response #{inspect response}")

    response
    |> validate_status_code!()
    |> check_signature!(api_secret)

    Poison.decode!(response.body)
  end

  defp check_signature!(%HTTPoison.Response{} = response, api_secret) do
    timestamp = get_header(response, "timestamp")
    signature = get_header(response, "authorization")

    case ProtocolSecurity.check_signature(response.body, nil, timestamp, api_secret, signature, @max_allowed_clock_skew) do
      :ok -> response
      error -> raise HTTPoison.Error, reason: "Invalid Unilink response signature, error: #{inspect error}"
    end
  end

  defp send_request!(url, payload, signature, timestamp) do
    Logger.info("Sending events to Unilink #{payload}, signature #{signature}, timestamp #{timestamp}")

    HTTPoison.post!(url, payload, [
      {"content-type", "application/json"},
      {"authorization", signature},
      {"timestamp", timestamp},
    ])
  end

  defp validate_status_code!(%HTTPoison.Response{status_code: code} = response) when code >= 200 and code < 300, do: response
  defp validate_status_code!(%HTTPoison.Response{status_code: code, body: body}) do
    raise HTTPoison.Error, reason: "Unilink events publish failed with HTTP status code #{code}, #{body}"
  end

  defp get_header(%HTTPoison.Response{headers: headers}, name) do
    headers
    |> Enum.find({name, ""}, fn {n, _} -> n == name end)
    |> elem(1)
  end
end
