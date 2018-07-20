defmodule UnilinkClient.Server do
  use GenServer
  alias UnilinkClient.{Config, ProcessScheduler}
  require Logger

  @batch_size 20

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    if Config.active? do
      Logger.info("Starting Unilink sync process")

      delay = Config.module.get_server_start_delay()
      Process.send_after(self(), :work, delay)
    end

    {:ok, []}
  end

  def handle_info(:work, state) do
    results =
      Config.settings()
      |> Enum.map(fn setting ->
        Logger.debug("Unilink - sending events for: #{inspect setting.name}")
        UnilinkClient.Process.next_state(Config.event_sources, @batch_size, setting)
      end)

    if Enum.any?(results, & &1 == :schedule_fast) do
      ProcessScheduler.schedule(10)
    else
      Config.module.get_server_lazy_work_delay()
      |> ProcessScheduler.schedule()
    end

    {:noreply, state}
  end
end
