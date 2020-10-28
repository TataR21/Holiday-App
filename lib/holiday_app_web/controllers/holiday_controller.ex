defmodule HolidayAppWeb.HolidayController do
  use HolidayAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def new(conn, _params) do

  end
end
