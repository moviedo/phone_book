defmodule PhoneBookWeb.PhoneControllerTest do
  use PhoneBookWeb.ConnCase

  import PhoneBook.{AccountsFixtures, ContactsFixtures}

  alias PhoneBook.Contacts.Phone

  @create_attrs %{
    label: :mobile,
    number: "+12122368399"
  }
  @update_attrs %{
    label: :home
  }
  @invalid_attrs %{label: nil, number: "+2358579723942387429347238947"}
  @contact_id "f53b37df-e281-42f4-a4bd-b7d4c717e19e"
  @phone_id "f53b37df-e281-42f4-a4bd-b7d4c717e19e"

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    %{conn: conn, user: user} = register_and_log_in_user(%{conn: conn})

    contact_attr = %{name: "some name", user_id: user.id}
    {:ok, contact} = PhoneBook.Contacts.create_contact(contact_attr)

    phone_attr = %{
      number: "+17182347788",
      label: :mobile,
      contact_id: contact.id
    }

    {:ok, phone} = PhoneBook.Contacts.create_phone(phone_attr)

    %{conn: conn, user: user, contact: contact, phone: phone}
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
    end

    test "renders errors when contact_id request data violates content policy", %{conn: conn} do
      contact2 = contact_fixture()

      conn =
        post(conn, Routes.contact_phone_path(conn, :create, contact2.id), phone: @create_attrs)

      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when request session violates content policy", %{
      conn: conn,
      contact: contact
    } do
      conn = log_in_user(conn, user_fixture())

      conn =
        post(conn, Routes.contact_phone_path(conn, :create, contact.id), phone: @create_attrs)

      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when contact_id request data doesn't exist", %{conn: conn} do
      response =
        assert_error_sent 404, fn ->
          post(
            conn,
            Routes.contact_phone_path(conn, :create, @contact_id),
            phone: @create_attrs
          )
        end

      assert {404, [_h | _t], "\"Not Found\""} = response
    end
  end

  describe "index" do
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

    test "renders error when request data violates content policy", %{conn: conn} do
      phone2 = phone_fixture()
      conn = get(conn, Routes.contact_phone_path(conn, :index, phone2.contact_id))
      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when request session violates content policy", %{
      conn: conn,
      contact: contact
    } do
      conn = log_in_user(conn, user_fixture())
      conn = get(conn, Routes.contact_phone_path(conn, :index, contact.id))

      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when contact_id request data doesn't exist", %{conn: conn} do
      response =
        assert_error_sent 404, fn ->
          get(conn, Routes.contact_phone_path(conn, :index, @contact_id))
        end

      assert {404, [_h | _t], "\"Not Found\""} = response
    end
  end

  describe "show" do
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

    test "renders errors when request data violates content policy", %{conn: conn, phone: phone1} do
      phone2 = phone_fixture()
      conn = get(conn, Routes.contact_phone_path(conn, :show, phone2.contact_id, phone1.id))
      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when request session violates content policy", %{
      conn: conn,
      contact: contact,
      phone: phone
    } do
      conn = log_in_user(conn, user_fixture())
      conn = get(conn, Routes.contact_phone_path(conn, :show, contact.id, phone.id))

      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when contact_id request data doesn't exist", %{conn: conn, phone: phone} do
      conn = get(conn, Routes.contact_phone_path(conn, :show, @contact_id, phone.id))
      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when phone_id request data doesn't exist", %{conn: conn, phone: phone} do
      response =
        assert_error_sent 404, fn ->
          get(conn, Routes.contact_phone_path(conn, :show, phone.contact_id, @phone_id))
        end

      assert {404, [_h | _t], "\"Not Found\""} = response
    end
  end

  describe "update phone" do
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
    end

    test "renders errors when request data violates content policy", %{conn: conn, phone: phone} do
      contact = contact_fixture()

      conn =
        put(
          conn,
          Routes.contact_phone_path(
            conn,
            :update,
            contact.id,
            phone.id
          ),
          phone: @update_attrs
        )

      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when request session violates content policy", %{
      conn: conn,
      contact: contact,
      phone: phone
    } do
      conn = log_in_user(conn, user_fixture())

      conn =
        put(conn, Routes.contact_phone_path(conn, :update, contact.id, phone.id),
          phone: @update_attrs
        )

      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when contact_id request data doesn't exist", %{conn: conn, phone: phone} do
      conn =
        put(conn, Routes.contact_phone_path(conn, :update, @contact_id, phone.id),
          phone: @update_attrs
        )

      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when phone_id request data doesn't exist", %{
      conn: conn,
      contact: contact
    } do
      response =
        assert_error_sent 404, fn ->
          put(conn, Routes.contact_phone_path(conn, :update, contact.id, @phone_id),
            phone: @update_attrs
          )
        end

      assert {404, [_h | _t], "\"Not Found\""} = response
    end
  end

  describe "delete phone" do
    test "deletes chosen phone", %{conn: conn, phone: phone} do
      conn = delete(conn, Routes.contact_phone_path(conn, :delete, phone.contact_id, phone.id))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.contact_phone_path(conn, :show, phone.contact_id, phone.id))
      end
    end

    test "renders errors when request data violates content policy", %{conn: conn, phone: phone} do
      phone2 = phone_fixture()
      conn = delete(conn, Routes.contact_phone_path(conn, :delete, phone2.contact_id, phone.id))
      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when request session violates content policy", %{
      conn: conn,
      contact: contact,
      phone: phone
    } do
      conn = log_in_user(conn, user_fixture())
      conn = delete(conn, Routes.contact_phone_path(conn, :delete, contact.id, phone.id))

      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when contact_id request data doesn't exist", %{conn: conn, phone: phone} do
      conn = delete(conn, Routes.contact_phone_path(conn, :delete, @contact_id, phone.id))
      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when phone_id request data doesn't exist", %{
      conn: conn,
      contact: contact
    } do
      response =
        assert_error_sent 404, fn ->
          delete(conn, Routes.contact_phone_path(conn, :delete, contact.id, @phone_id))
        end

      assert {404, [_h | _t], "\"Not Found\""} = response
    end
  end
end
