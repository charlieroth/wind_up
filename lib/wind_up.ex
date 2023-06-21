defmodule WindUp do
  @moduledoc """
  WindUp keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @spec create_alarm(Date.t(), Date.t()) :: {:ok, String.t()} | {:error, String.t()}
  def create_alarm(start_time, end_time) do
    {:ok, "alarm-id"}
  end
end
