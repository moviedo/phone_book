defmodule PhoneBookWeb.VueControllerTest do
  use PhoneBookWeb.ConnCase, async: true

  setup %{conn: conn} do
    register_and_log_in_user(%{conn: conn})
  end

  test "GET /phonebook/*", %{conn: conn} do
    conn = get(conn, Routes.vue_path(conn, :index, []))
    assert html_response(conn, 200) =~ "phonebook"

    conn = get(conn, Routes.vue_path(conn, :index, ["contact/123/"]))
    assert html_response(conn, 200) =~ "phonebook"
  end
end
