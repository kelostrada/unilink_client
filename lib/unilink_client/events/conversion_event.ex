defmodule UnilinkClient.ConversionEvent do
  defstruct event_id: nil, type: "conversion", user_id: nil, affiliate_id: nil, tracking_id: nil, name: nil, timestamp: nil, country_code: nil, user_agent: nil
end
