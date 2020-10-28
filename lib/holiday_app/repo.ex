defmodule HolidayApp.Repo do
  use Ecto.Repo,
    otp_app: :holiday_app,
    adapter: Ecto.Adapters.Postgres
end
