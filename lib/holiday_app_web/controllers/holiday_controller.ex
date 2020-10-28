defmodule HolidayAppWeb.HolidayController do
  use HolidayAppWeb, :controller
  alias HolidayApp.Repo
  alias HolidayAppWeb.Holiday
  import Ecto.Query, only: [from: 2]

  def index(conn, _params) do
    holiday_table = get_data_for_logged_in_user(conn)
    all_days = Enum.map(holiday_table, fn x -> x.days end)
    list_days = Enum.flat_map(all_days, fn x -> x end )
    days_to_used = 20 - length(list_days)
    render(conn, "index.html", holiday_table: holiday_table, days_to_used: days_to_used)
  end

  def new(conn, _params) do
    changeset = Holiday.changeset(%Holiday{}, %{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"holiday" => new_row}) do
    map_add_days = Map.put_new(new_row, "days", list_of_days(new_row["date_start"],new_row["date_end"]))
    map = Map.put_new(map_add_days, "id_user", Pow.Plug.current_user(conn).id)
    changeset = Holiday.changeset(%Holiday{}, map)
    data = get_data_for_logged_in_user(conn)
    list_days = return_list_of_days(data)
    changeset = check_days_overlap(map, list_days, changeset)
    changeset = check_if_the_days_are_used(map, list_days, changeset)
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

  def edit(conn, %{"id" => row_id}) do
    holiday_row = Repo.get(Holiday, row_id)
    changeset = Holiday.changeset(holiday_row)
    render conn, "edit.html", changeset: changeset, holiday_row: holiday_row
  end

  def update(conn, %{"id" => row_id, "holiday" => new_row}) do
    {id,_tail} = Integer.parse(row_id)
    list_days = get_repo_for_update_return_list_of_days(id, conn)
    map = Map.put_new(new_row, "days", list_of_days(new_row["date_start"],new_row["date_end"]))
    map = Map.put_new(map, "id_user", Pow.Plug.current_user(conn).id)
    old_row = Repo.get(Holiday, row_id)
    changeset = Holiday.changeset(old_row, map)
    changeset = check_days_overlap(map, list_days, changeset)
    changeset = check_if_the_days_are_used(map, list_days, changeset)
    case Repo.update(changeset) do
      {:ok, _test_field} ->
        conn
        |> put_flash(:info, "Edytowano przedział")
        |> redirect(to: Routes.holiday_path(conn, :index))
      {:error, changeset} -> render conn, "edit.html", changeset: changeset, holiday_row: old_row
    end

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

  def check_days_overlap(new_row, list_days, changeset) do
    case Enum.any?(list_days, fn x -> x in new_row["days"] end) do
      true -> Ecto.Changeset.add_error(changeset, :date_start, "Przedziały nie mogą się nakładać!")
      false -> changeset
    end
  end

  defp check_if_the_days_are_used(new_row, list_days, changeset) do
    days_used = length(list_days)
    days_from_changeset = length(new_row["days"])
    if days_used+days_from_changeset<=20 do
      changeset
    else
      Ecto.Changeset.add_error(changeset, :date_start, "Liczba dni urlopowych została wykorzystana.
      Można wykorzystać maksymalnie 20 dni. Wybierz krótszy przedział")
    end
  end

  def return_list_of_days(all_data) do
    all_data
    |>Enum.map(fn x -> x.days end)
    |>Enum.flat_map(fn x -> x end )
  end
  def get_repo_for_update_return_list_of_days(row_id, conn) do
    user_id = Pow.Plug.current_user(conn).id
    query = from u in "holiday", where: u.id != ^row_id and u.id_user == ^user_id, select: u.days
    all_data = Repo.all(query)
    all_data
    |>Enum.flat_map(fn x -> x end )
  end

  def get_data_for_logged_in_user(conn) do
   user_id = Pow.Plug.current_user(conn).id
   query = from u in Holiday, where: u.id_user == ^user_id, select: u
   Repo.all(query)
  end

end
