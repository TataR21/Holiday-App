defmodule HolidayAppWeb.HolidayController do
  use HolidayAppWeb, :controller
  alias HolidayApp.Repo
  alias HolidayAppWeb.Holiday
  import HolidayApp.HolidayModule
  import HolidayApp.Static_var
  alias HolidayApp.Static_var

  def index(conn, _params) do
    holiday_table = get_data_for_logged_in_user(conn)
    list_days = return_list_of_days(holiday_table)
    days_to_used = %Static_var{}.vacation_days - length(list_days)
    render(conn, "index.html", holiday_table: holiday_table, days_to_used: days_to_used)
  end

  def new(conn, _params) do
    changeset = Holiday.changeset(%Holiday{}, %{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"holiday" => new_row}) do
    map = put_days_list_and_id_user(conn, new_row)
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
    map = put_days_list_and_id_user(conn, new_row)
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

end
