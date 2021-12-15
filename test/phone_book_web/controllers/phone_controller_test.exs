defmodule PhoneBookWeb.PhoneControllerTest do
  use PhoneBookWeb.ConnCase

  import PhoneBook.ContactsFixtures

  alias PhoneBook.Contacts.Phone

  @create_attrs %{
    label: :mobile,
    number: "+12122368399"
  }
  @update_attrs %{
    label: :home
  }
  @invalid_attrs %{label: nil, number: "+2358579723942387429347238947"}

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    %{conn: conn} = register_and_log_in_user(%{conn: conn})
    %{conn: conn, contact: contact_fixture()}
  end

  describe "create phone" do
    test "renders phone when data is valid", %{conn: conn, contact: contact} do
      conn =
        post(conn, Routes.contact_phone_path(conn, :create, contact.id), phone: @create_attrs)

      number = @create_attrs.number

      assert %{
               "label" => "mobile",
               "number" => ^number,
               "id" => _,
               "inserted_at" => _
             } = json_response(conn, 201)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, contact: contact} do
      conn =
        post(conn, Routes.contact_phone_path(conn, :create, contact.id), phone: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}

      conn =
        post(
          conn,
          Routes.contact_phone_path(conn, :create, "f53b37df-e281-42f4-a4bd-b7d4c717e19e"),
          phone: @create_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "index" do
    setup [:create_phone]

    test "lists all phones", %{conn: conn, phone: phone} do
      conn = get(conn, Routes.contact_phone_path(conn, :index, phone.contact_id))

      assert [
               %{
                 "id" => phone.id,
                 "number" => phone.number,
                 "label" => "mobile",
                 "inserted_at" => NaiveDateTime.to_iso8601(phone.inserted_at)
               }
             ] == json_response(conn, 200)["data"]
    end
  end

  describe "show" do
    setup [:create_phone]

    test "renders selected phone data", %{conn: conn, phone: phone} do
      %{contact_id: contact_id, id: id, inserted_at: inserted_at, number: number} = phone
      conn = get(conn, Routes.contact_phone_path(conn, :show, contact_id, id))
      inserted_at = NaiveDateTime.to_iso8601(inserted_at)

      assert %{
               "id" => ^id,
               "inserted_at" => ^inserted_at,
               "label" => "mobile",
               "number" => ^number
             } = json_response(conn, 200)["data"]
    end

    test "renders authorization error when data is invalid", %{conn: conn, phone: phone1} do
      phone2 = phone_fixture()
      conn = get(conn, Routes.contact_phone_path(conn, :show, phone2.contact_id, phone1.id))
      assert json_response(conn, 401)["errors"] == ["Unauthorized"]
    end
  end

  describe "update phone" do
    setup [:create_phone]

    test "renders phone when data is valid", %{conn: conn, phone: phone} do
      %Phone{id: id, number: number, inserted_at: inserted_at, contact_id: contact_id} = phone

      conn =
        put(conn, Routes.contact_phone_path(conn, :update, contact_id, phone),
          phone: @update_attrs
        )

      inserted_at = NaiveDateTime.to_iso8601(inserted_at)

      assert %{
               "id" => ^id,
               "number" => ^number,
               "label" => "home",
               "inserted_at" => ^inserted_at
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, phone: phone} do
      conn =
        put(conn, Routes.contact_phone_path(conn, :update, phone.contact_id, phone.id),
          phone: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}

      conn =
        put(
          conn,
          Routes.contact_phone_path(
            conn,
            :update,
            "f53b37df-e281-42f4-a4bd-b7d4c717e19e",
            phone.id
          ),
          phone: @update_attrs
        )

      assert json_response(conn, 401)["errors"] != %{}
    end
  end

  describe "delete phone" do
    setup [:create_phone]

    test "deletes chosen phone", %{conn: conn, phone: phone} do
      conn = delete(conn, Routes.contact_phone_path(conn, :delete, phone.contact_id, phone.id))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.contact_phone_path(conn, :show, phone.contact_id, phone.id))
      end
    end

    test "renders errors when data is invalid", %{conn: conn, phone: phone} do
      phone2 = phone_fixture()
      conn = delete(conn, Routes.contact_phone_path(conn, :delete, phone2.contact_id, phone.id))
      assert json_response(conn, 401)["errors"] != %{}
    end
  end

  defp create_phone(_) do
    phone = phone_fixture()
    %{phone: phone}
  end
end
