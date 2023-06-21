defmodule WindUp.Repo do
  use Ecto.Repo,
    otp_app: :wind_up,
    adapter: Ecto.Adapters.Postgres
end
