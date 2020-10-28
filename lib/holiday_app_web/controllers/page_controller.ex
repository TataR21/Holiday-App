defmodule HolidayAppWeb.PageController do
  use HolidayAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
