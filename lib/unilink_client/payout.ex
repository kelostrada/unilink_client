defmodule UnilinkClient.Payout do

  def format(params) do
    %{"id" => id, "user_id" => user_id, "amount" => amount, "timestamp" => timestamp} = params
    %{
      id: id,
      user_id: user_id,
      amount: Decimal.new(amount),
      timestamp: timestamp
    }
  end

end
