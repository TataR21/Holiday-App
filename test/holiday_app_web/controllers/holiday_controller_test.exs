defmodule HolidayAppWeb.HolidayControllerTest do
  use HolidayAppWeb.ConnCase
  alias HolidayApp.Repo
  alias HolidayAppWeb.Holiday

  @create_attrs %{id_user: 1, date_start: "2020-11-02", date_end: "2020-11-05", reason: "Urlopik", days: ["2020-11-02", "2020-11-03", "2020-11-04", "2020-11-05"]}
  @invalid_attrs_empty %{id_user: 1, date_start: "", date_end: "2020-11-05", reason: "Urlopik"}
  @invalid_attrs_date %{id_user: 1, date_start: "2020-11-02", date_end: "2020-11-01", reason: "Urlopik"}
  @invalid_attrs_date_to_long %{id_user: 1, date_start: "2020-11-02", date_end: "2020-11-30", reason: "Urlopik"}
  @create_attrs_edit %{"id_user" => 1, "date_start" => "2020-11-02", "date_end" => "2020-11-05", "reason" => "Urlopik", "days" => ["2020-11-02", "2020-11-03", "2020-11-04", "2020-11-05"]}
  @update_attrs %{id_user: 1, date_start: "2020-11-03", date_end: "2020-11-06", reason: "Urlopik", days: ["2020-11-03", "2020-11-04", "2020-11-05", "2020-11-06"]}


  setup %{conn: conn} do
   user = %HolidayApp.Users.User{email: "test@example.com", id: 1}
   conn = Pow.Plug.assign_current_user(conn, user, [])

   {:ok, conn: conn}
 end

  describe "index" do
   test "index", %{conn: conn} do
     conn = get(conn, Routes.holiday_path(conn, :index))
     assert html_response(conn, 200) =~ "Lista dat urlopowych:"
   end
 end

 describe "new" do
   test "new", %{conn: conn} do
     conn = get(conn, Routes.holiday_path(conn, :new))
     assert html_response(conn, 200) =~ "Dodaj nowy urlop"
   end
 end

 describe "create" do
   test "redirect to index when data is valid", %{conn: conn} do
     authed_conn = conn
     conn = post(conn, Routes.holiday_path(conn, :create), holiday: @create_attrs)

     assert %{} = redirected_params(conn)
     assert redirected_to(conn) == Routes.holiday_path(conn, :index)

     conn = get(authed_conn, Routes.holiday_path(authed_conn, :index))

     assert html_response(conn, 200) =~ "Lista dat urlopowych:"
     #assert get_flash(conn, :info) == "Dodano nowy przedział"
   end
   test "renders errors when date is empty", %{conn: conn} do
     conn = post(conn, Routes.holiday_path(conn, :create), holiday: @invalid_attrs_empty)
     assert html_response(conn, 200) =~ "Dodaj nowy urlop"
   end

   test "renders errors when date end is earlier than start", %{conn: conn} do
     conn = post(conn, Routes.holiday_path(conn, :create), holiday: @invalid_attrs_date)
     assert html_response(conn, 200) =~ "Dodaj nowy urlop"
   end
   test "renders errors when holiday is larger than 20 days", %{conn: conn} do
    conn = post(conn, Routes.holiday_path(conn, :create), holiday: @invalid_attrs_date_to_long)
    assert html_response(conn, 200) =~ "Dodaj nowy urlop"
  end
 end

 describe "edit" do
  setup [:create_post]

  test "renders form for editing", %{conn: conn, holiday: holiday} do
    conn = get(conn, Routes.holiday_path(conn, :edit, holiday))
    assert html_response(conn, 200) =~ "Edytuj urlop"
  end
end

describe "update" do
  setup [:create_post]

  test "redirect to index when data is valid", %{conn: conn, holiday: holiday} do
    authed_conn = conn
    conn = put(conn, Routes.holiday_path(conn, :update, holiday), holiday: @update_attrs)
    assert redirected_to(conn) == Routes.holiday_path(conn, :index)

    conn = get(authed_conn , Routes.holiday_path(authed_conn , :index))
    assert html_response(conn, 200) =~ "Lista dat urlopowych:"
  end
  test "renders errors when date is empty", %{conn: conn, holiday: holiday} do
    conn = put(conn, Routes.holiday_path(conn, :update, holiday), holiday: @invalid_attrs_empty)
    assert html_response(conn, 200) =~ "Edytuj urlop"
  end

  test "renders errors when date end is earlier than start", %{conn: conn, holiday: holiday} do
    conn = put(conn, Routes.holiday_path(conn, :update, holiday), holiday: @invalid_attrs_date)
    assert html_response(conn, 200) =~ "Edytuj urlop"
  end
  test "renders errors when holiday is larger than 20 days", %{conn: conn, holiday: holiday} do
    conn = put(conn, Routes.holiday_path(conn, :update, holiday), holiday: @invalid_attrs_date_to_long)
    assert html_response(conn, 200) =~ "Edytuj urlop"
  end
end

describe "delete post" do
  setup [:create_post]

  test "deletes date", %{conn: conn, holiday: holiday} do
    authed_conn = conn
    conn = delete(conn, Routes.holiday_path(conn, :delete, holiday))
    assert redirected_to(conn) == Routes.holiday_path(conn, :index)
    conn = get(authed_conn, Routes.holiday_path(authed_conn, :index))
    assert html_response(conn, 200) =~ "Lista dat urlopowych:"

  end
end
  defp create_post(_) do
    attrs = @create_attrs_edit
    x = Holiday.changeset(%Holiday{}, attrs)
    {:ok, holiday} = Repo.insert(x)
    %{holiday: holiday}
  end
end
