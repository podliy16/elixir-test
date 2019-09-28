defmodule AwesomeElixir.Parser do
  @moduledoc false
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(_) do
    schedule_work()
    Logger.info("create");
    {:ok, %{}}
  end

  def handle_info(:parse, _) do
    schedule_work()
    #Logger.info("work")
    {:noreply, :ok}
  end

  @daily 24 * 60 * 60 * 1000
  @every_5_seconds 5 * 1000
  defp schedule_work do
    Process.send_after(self(), :parse, @every_5_seconds)
    Process
  end
end
