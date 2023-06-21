defmodule WindUp do
  @moduledoc """
  WindUp keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Ecto.UUID
  alias WindUp.TimerSupervisor

  @seconds_in_a_day 86400

  @spec add_alarm(Date.t(), Date.t()) :: {:error, term()} | {:ok, String.t(), pid()}
  def add_alarm(_start_time, _end_time) do
    {:error, :not_implemented}
  end

  @spec create_timer(integer()) :: {:error, term()} | {:ok, String.t(), pid()}
  def create_timer(number_of_seconds) do
    with true <- number_of_seconds < @seconds_in_a_day do
      id = UUID.autogenerate()
      {:ok, pid} = TimerSupervisor.add_timer(id, number_of_seconds)
      {:ok, id, pid}
    else
      _ ->
        {:error, :timer_longer_than_one_day}
    end
  end
end
