defmodule PhoneBookWeb.VueController do
  use PhoneBookWeb, :controller

  def index(conn, _params) do
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> Plug.Conn.send_file(200, "priv/vue_app/index.html")
    |> halt()
  end
end
