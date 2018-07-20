defmodule UnilinkClient do
  @moduledoc """
  Documentation for UnilinkClient.
  """

  @doc """
  Invoked to get API keys and secrets. Allows to setup multiple platforms.

  Typically you want to implement it to return just UnilinkClient.Setting struct.
  """
  @callback get_settings() ::
    [UnilinkClient.Setting.t]
    | UnilinkClient.Setting.t

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

      defoverridable  get_server_start_delay: 0,
                      get_server_lazy_work_delay: 0
    end
  end
end
