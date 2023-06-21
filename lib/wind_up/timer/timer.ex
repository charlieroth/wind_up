defmodule WindUp.Timer do
  use GenServer, restart: :transient
  require Logger

  def start_link({id, _number_of_seconds} = args) do
    GenServer.start_link(__MODULE__, args, name: via_tuple(id))
  end

  def child_spec({_id, _number_of_seconds} = args) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, [args]}}
  end

  @impl true
  def init({id, number_of_seconds}) do
    :ok = Phoenix.PubSub.subscribe(WindUp.PubSub, "timer:#{id}")
    Process.send_after(self(), :tick, 1000)

    {
      :ok,
      %{
        id: id,
        number_of_seconds: number_of_seconds,
        time_elapsed: 0,
        completed: false
      }
    }
  end

  @impl true
  def handle_info(:tick, state) do
    new_time_elapsed = state.time_elapsed + 1
    Logger.info("tick: #{inspect(new_time_elapsed)}")

    if new_time_elapsed == state.number_of_seconds do
      new_state = %{state | completed: true, time_elapsed: new_time_elapsed}
      Logger.info("timer '#{state.id}' done!")
      {:noreply, new_state}
    else
      new_state = %{state | time_elapsed: new_time_elapsed}
      Process.send_after(self(), :tick, 1000)
      {:noreply, new_state}
    end
  end

  defp via_tuple(alarm_id), do: {:via, Registry, {WindUp.Registry, alarm_id}}
end
