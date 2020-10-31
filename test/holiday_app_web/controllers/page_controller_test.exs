defmodule HolidayAppWeb.PageControllerTest do
  use HolidayAppWeb.ConnCase
  alias HolidayApp.Repo
  alias HolidayAppWeb.Holiday
  import HolidayApp.HolidayModule

  #test "GET /", %{conn: conn} do
   # conn = get(conn, "/")
   # assert html_response(conn, 200) =~ "Welcome to Phoenix!"
 # end



 setup %{conn: conn} do
  user = %HolidayApp.Users.User{email: "test@example.com", id: 1}
  conn = Pow.Plug.assign_current_user(conn, user, otp_app: :my_app)

  {:ok, conn: conn}
end


 describe "index" do
  test "lists all posts", %{conn: conn} do
    IO.inspect(conn)
    conn = get(conn, Routes.holiday_path(conn, :index))
    assert html_response(conn, 200) =~ "Lista dat urlopowych:"
  end
end

describe "new post" do
  test "renders form", %{conn: conn} do
    conn = get(conn, Routes.holiday_path(conn, :new))
    assert html_response(conn, 200) =~ "New Post"
  end
end

end
