defmodule UnilinkClient do
  @moduledoc """
  Documentation for UnilinkClient.
  """

  @typedoc """
  Profit map returned by Unilink service in callback when user requests payout.
  Should be used in `handle_profit/1` callback to add user balance.
  """
  @type profit :: %{
    id: String.t(),
    user_id: String.t(),
    amount: Decimal.t(),
    timestamp: integer
  }

  @doc """
  Invoked to get API keys and secrets. Allows to setup multiple platforms.

  Typically you want to implement it to return just `UnilinkClient.Setting` struct.
  It is possible to return multiple `UnilinkClient.Setting` structs (in a list)
  if you handle multiple Unilink accounts in one service.
  """
  @callback get_settings() ::
    [UnilinkClient.Setting.t]
    | UnilinkClient.Setting.t

  @doc """
  Invoked when user requests withdrawal of his affiliation funds.

  Unilink follows at least once delivery semantics and will retry requests until
  successful response is received. Client Platform may receive the same request
  more than once and SHOULD make sure that users profit is assigned only once for
  each unique ID of payout request. Client Platform SHOULD respond with code 202
  upon receival of already processed payout request.
  """
  @callback handle_profit(profit) :: :ok | {:error, atom}

  @doc """
  Invoked at server start to delay startup
  """
  @callback get_server_start_delay() :: integer

  @doc """
  Invoked on lazy work to delay it
  """
  @callback get_server_lazy_work_delay() :: integer

  @optional_callbacks get_server_start_delay: 0,
                      get_server_lazy_work_delay: 0

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour UnilinkClient

      @doc false
      def get_server_start_delay(), do: 5000

      @doc false
      def get_server_lazy_work_delay(), do: 1000

      def get_login_url(api_key, user_id) do
        UnilinkClient.Uri.login(api_key, user_id)
      end

      defoverridable  get_server_start_delay: 0,
                      get_server_lazy_work_delay: 0
    end
  end
end
