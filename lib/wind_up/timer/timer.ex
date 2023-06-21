defmodule WindUp.Timer do
  use GenServer, restart: :transient
  require Logger

  def state(id) do
    GenServer.call(via_tuple(id), :state)
  end

  def pause(id) do
    GenServer.cast(via_tuple(id), :pause)
  end

  def resume(id) do
    GenServer.cast(via_tuple(id), :resume)
  end

  def start_link({id, _number_of_seconds} = args) do
    GenServer.start_link(__MODULE__, args, name: via_tuple(id))
  end

  def child_spec(args) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, [args]}}
  end

  @impl true
  def init({id, number_of_seconds}) do
    :ok = Phoenix.PubSub.subscribe(WindUp.PubSub, "timer:#{id}")
    timer_ref = Process.send_after(self(), :tick, 1000)

    {
      :ok,
      %{
        id: id,
        timer_ref: timer_ref,
        number_of_seconds: number_of_seconds,
        time_elapsed: 0,
        completed: false
      }
    }
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast(:pause, state) do
    with :ok <- Process.cancel_timer(state.timer_ref, async: false, info: true) do
      Logger.info("#{state.id}:paused")
      {:noreply, %{state | timer_ref: nil}}
    else
      reason ->
        Logger.info("#{state.id}:failed_to_pause:#{inspect(reason)}")
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast(:resume, state) do
    Logger.info("#{state.id}:resumed")
    timer_ref = Process.send_after(self(), :tick, 1000)
    {:noreply, %{state | timer_ref: timer_ref}}
  end

  @impl true
  def handle_info(:tick, state) do
    new_time_elapsed = state.time_elapsed + 1
    # Logger.info("#{state.id}:tick:#{new_time_elapsed}")

    if new_time_elapsed == state.number_of_seconds do
      new_state = %{state | completed: true, time_elapsed: new_time_elapsed}
      Logger.info("#{state.id}:done")
      {:noreply, new_state}
    else
      new_state = %{state | time_elapsed: new_time_elapsed}
      Process.send_after(self(), :tick, 1000)
      {:noreply, new_state}
    end
  end

  defp via_tuple(alarm_id), do: {:via, Registry, {WindUp.Registry, alarm_id}}
end
