defmodule UnilinkClient.ProcessScheduler do
  def schedule(ms) when is_integer(ms) do
    Process.send_after(self(), :work, ms)
  end
end
