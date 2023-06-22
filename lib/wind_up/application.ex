defmodule WindUp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, [keys: :unique, name: WindUp.Registry]},
      # WindUpWeb.Telemetry,
      # WindUp.Repo,
      {Phoenix.PubSub, name: WindUp.PubSub},
      # {Finch, name: WindUp.Finch},
      # WindUpWeb.Endpoint
      # {WindUp.Timer.Supervisor, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WindUp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WindUpWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
