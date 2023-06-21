defmodule WindUp.TimerSupervisor do
  use DynamicSupervisor
  alias WindUp.Timer

  @spec add_timer(String.t(), integer()) ::
          :ignore | {:error, any()} | {:ok, pid()} | {:ok, pid(), any()}
  def add_timer(timer_id, number_of_seconds) do
    child_spec = {Timer, {timer_id, number_of_seconds}}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
