defmodule PhoneBookWeb.PageController do
  use PhoneBookWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
