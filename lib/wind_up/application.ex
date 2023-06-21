defmodule WindUp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      WindUpWeb.Telemetry,
      # Start the Ecto repository
      WindUp.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: WindUp.PubSub},
      # Start Finch
      {Finch, name: WindUp.Finch},
      # Start the Endpoint (http/https)
      WindUpWeb.Endpoint
      # Start a worker by calling: WindUp.Worker.start_link(arg)
      # {WindUp.Worker, arg}
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
