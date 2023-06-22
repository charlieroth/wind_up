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

  def reset(id) do
    GenServer.cast(via_tuple(id), :reset)
  end

  def cancel(id) do
    GenServer.call(via_tuple(id), :cancel)
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
        status: :running,
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
  def handle_call(:cancel, _from, state) do
    with :ok <- Process.cancel_timer(state.timer_ref, async: true, info: false) do
      new_state = %{state | timer_ref: nil, status: :canceled}
      Logger.info("#{state.id}:canceled")
      {:reply, new_state, new_state}
    else
      reason ->
        Logger.error("Failed to cancel timer: #{state.id}, #{inspect(reason)}")
        {:reply, state, state}
    end
  end

  @impl true
  def handle_cast(:reset, state) do
    with :ok <- Process.cancel_timer(state.timer_ref, async: true, info: false) do
      timer_ref = Process.send_after(self(), :tick, 1000)
      new_state = %{state | timer_ref: timer_ref, status: :running, time_elapsed: 0}
      Logger.info("#{state.id}:reset")
      {:noreply, new_state}
    else
      reason ->
        Logger.error("Failed to cancel timer: #{state.id}, #{inspect(reason)}")
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast(:pause, state) do
    with :ok <- Process.cancel_timer(state.timer_ref, async: true, info: false) do
      {:noreply, %{state | timer_ref: nil, status: :paused}}
    else
      reason ->
        Logger.error("#{state.id}:failed_to_pause:#{inspect(reason)}")
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast(:resume, state) do
    Logger.info("#{state.id}:resumed")
    timer_ref = Process.send_after(self(), :tick, 1000)
    {:noreply, %{state | timer_ref: timer_ref, status: :running}}
  end

  @impl true
  def handle_info(:tick, state) do
    new_time_elapsed = state.time_elapsed + 1

    if new_time_elapsed == state.number_of_seconds do
      with :ok <- Process.cancel_timer(state.timer_ref, async: true, info: false) do
        new_state = %{
          state
          | completed: true,
            time_elapsed: new_time_elapsed,
            status: :done,
            timer_ref: nil
        }

        Logger.info("#{state.id}:done")
        {:noreply, new_state}
      else
        reason ->
          Logger.error("Failed to cancel timer: #{inspect(reason)}")
          {:noreply, state}
      end
    else
      with :ok <- Process.cancel_timer(state.timer_ref, async: true, info: false) do
        timer_ref = Process.send_after(self(), :tick, 1000)
        new_state = %{state | time_elapsed: new_time_elapsed, timer_ref: timer_ref}
        {:noreply, new_state}
      else
        reason ->
          Logger.error("Failed to cancel timer: #{inspect(reason)}")
          {:noreply, state}
      end
    end
  end

  defp via_tuple(alarm_id), do: {:via, Registry, {WindUp.Registry, alarm_id}}
end
