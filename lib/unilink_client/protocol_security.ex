defmodule UnilinkClient.ProtocolSecurity do
  require Logger

  def signature(body, query_string, timestamp, secret) when is_integer(timestamp), do: signature(body, query_string, timestamp |> Integer.to_string, secret)
  def signature(body, query_string, timestamp, secret) do
    Logger.debug "Computing signature with body: #{body}, timestamp: #{timestamp}, secret: #{secret}"

    :crypto.hmac_init(:sha256, secret)
    |> :crypto.hmac_update(body || "")
    |> :crypto.hmac_update(query_string || "")
    |> :crypto.hmac_update(timestamp)
    |> :crypto.hmac_final
    |> Base.encode16
  end

  def check_signature(body, query_string, timestamp, secret, signature, max_allowed_clock_skew) do
    cond do
      not timestamp_valid?(timestamp, max_allowed_clock_skew) ->
        {:error, :timestamp_outside_margin}
      not signature_valid?(body, query_string, timestamp, secret, signature) ->
        {:error, :signature_not_matching}
      true -> :ok
    end
  end

  defp signature_valid?(received_body, query_string, timestamp, secret, received_signature) do
    signature = String.upcase(received_signature)
    hmac = signature(received_body, query_string, timestamp, secret)

    hmac == signature
  end

  defp timestamp_valid?(timestamp, max_allowed_clock_skew) when is_integer(timestamp) do
    current_timestamp = :os.system_time(:seconds)
    abs(current_timestamp - timestamp) <= max_allowed_clock_skew
  end

  defp timestamp_valid?(timestamp, max_allowed_clock_skew) do
    case Integer.parse timestamp do
      {value, _} -> timestamp_valid?(value, max_allowed_clock_skew)
      _ -> false
    end
  end
end
