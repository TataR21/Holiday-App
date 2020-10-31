defmodule HolidayApp.HolidayModule do
  alias HolidayApp.Repo
  alias HolidayAppWeb.Holiday
  import Ecto.Query, only: [from: 2]
  import HolidayApp.Static_var
  alias HolidayApp.Static_var
  @doc """
    Take two arguments date_start and date_end and return list of days in range of date_start and date_end

    ##Examples

      iex>HolidayApp.HolidayModule.list_of_days("2020-10-10","2020-10-12")
      ["2020-10-10", "2020-10-11", "2020-10-12"]

"""
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
    case Enum.any?(list_days, fn x -> x in new_row end) do
      true -> Ecto.Changeset.add_error(changeset, :date_start, "Przedziały nie mogą się nakładać!")
      false -> changeset
    end
  end

  def check_if_the_days_are_used(new_row, list_days, changeset) do
    days_used = length(list_days)
    days_from_changeset = length(new_row)
    if days_used+days_from_changeset<=%Static_var{}.vacation_days do
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

  def put_days_list_and_id_user(conn, new_row) do
    map = Map.put_new(new_row, "days", list_of_days(new_row["date_start"],new_row["date_end"]))
    Map.put_new(map, "id_user", Pow.Plug.current_user(conn).id)
  end
end
