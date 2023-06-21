defmodule WindUp.Timer.Supervisor do
  use DynamicSupervisor
  alias WindUp.Timer

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_alarm(alarm_id) do
    child_spec = {Timer, alarm_id}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
