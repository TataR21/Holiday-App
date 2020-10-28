defmodule HolidayAppWeb.HolidayController do
  use HolidayAppWeb, :controller
  alias HolidayApp.Repo
  alias HolidayAppWeb.Holiday

  def index(conn, _params) do
    holiday_table = Repo.all(Holiday)
    render(conn, "index.html", holiday_table: holiday_table)
  end

  def new(conn, _params) do
    changeset = Holiday.changeset(%Holiday{}, %{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"holiday" => new_row}) do
    map_add_days = Map.put_new(new_row, "days", list_of_days(new_row["date_start"],new_row["date_end"]))
    map = Map.put_new(map_add_days, "id_user", Pow.Plug.current_user(conn).id)
    changeset = Holiday.changeset(%Holiday{}, map)
    case Repo.insert(changeset) do
      {:ok, _tail} ->
        conn
        |> put_flash(:info, "Dodano nowy przedział")
        |> redirect(to: Routes.holiday_path(conn, :index))
      {:error, changeset} -> render conn, "new.html", changeset: changeset
    end
  end

  def delete(conn, %{"id" => row_id}) do
    Repo.get!(Holiday, row_id) |> Repo.delete!()
    conn
    |> put_flash(:info, "Przedział usunięty")
    |> redirect(to: Routes.holiday_path(conn, :index))
  end

  def list_of_days(date_start, date_end) do
    if date_start !== "" && date_end !== "" do
      start_date = Date.from_iso8601!(date_start)
      end_date = Date.from_iso8601!(date_end)
      range = Date.range(start_date, end_date)
      Enum.map(range, fn x-> Date.to_string(x) end)
    else
      []
    end
  end
end
