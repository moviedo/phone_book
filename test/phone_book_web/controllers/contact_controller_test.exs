defmodule PhoneBookWeb.ContactControllerTest do
  use PhoneBookWeb.ConnCase

  import PhoneBook.{AccountsFixtures, ContactsFixtures}
  alias PhoneBook.Contacts
  alias PhoneBook.Contacts.Contact

  @create_attrs %{
    name: "Tom Hardy"
  }
  @update_attrs %{
    name: "Jesse James"
  }
  @invalid_attrs %{name: nil}

  setup %{conn: conn} do
    conn = put_req_header(conn, "accept", "application/json")
    %{conn: conn, user: user} = register_and_log_in_user(%{conn: conn})

    {:ok, contact} =
      PhoneBook.Contacts.create_contact(%{
        name: "some name",
        user_id: user.id
      })

    %{conn: conn, user: user, contact: contact}
  end

  describe "create contact" do
    test "renders contact when data is valid", %{conn: conn} do
      conn = post(conn, Routes.contact_path(conn, :create), contact: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.contact_path(conn, :show, id))
      name = @create_attrs.name

      assert %{
               "id" => ^id,
               "name" => ^name
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.contact_path(conn, :create), contact: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "index" do
    test "lists all contacts", %{conn: conn, contact: contact} do
      conn = get(conn, Routes.contact_path(conn, :index))

      assert json_response(conn, 200)["data"] == [
               %{
                 "id" => contact.id,
                 "name" => contact.name,
                 "phones" => []
               }
             ]
    end

    test "lists all contacts with associated phone number(s)", %{conn: conn, contact: contact} do
      {:ok, phone} =
        Contacts.create_phone(%{
          number: "+17182347788",
          label: :mobile,
          contact_id: contact.id
        })

      phone = %{
        "id" => phone.id,
        "number" => "+17182347788",
        "label" => "mobile",
        "inserted_at" => NaiveDateTime.to_iso8601(phone.inserted_at)
      }

      conn = get(conn, Routes.contact_path(conn, :index))

      assert json_response(conn, 200)["data"] == [
               Map.put(
                 %{
                   "name" => contact.name,
                   "id" => contact.id
                 },
                 "phones",
                 [phone]
               )
             ]
    end
  end

  describe "show" do
    test "renders contact when data is valid, with associated phone number(s)", %{conn: conn} do
      conn = post(conn, Routes.contact_path(conn, :create), contact: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      {:ok, %{id: phone_id, inserted_at: inserted_at, number: number}} =
        Contacts.create_phone(%{
          number: "+17182347788",
          label: :mobile,
          contact_id: id
        })

      conn = get(conn, Routes.contact_path(conn, :show, id))
      name = @create_attrs.name
      inserted_at = NaiveDateTime.to_iso8601(inserted_at)

      assert %{
               "id" => ^id,
               "name" => ^name,
               "phones" => [
                 %{
                   "id" => ^phone_id,
                   "inserted_at" => ^inserted_at,
                   "label" => "mobile",
                   "number" => ^number
                 }
               ]
             } = json_response(conn, 200)["data"]
    end

    test "renders authorization error when data is invalid", %{conn: conn} do
      contact = contact_fixture()
      conn = get(conn, Routes.contact_path(conn, :show, contact.id))
      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when request session violates content policy", %{
      conn: conn,
      contact: contact
    } do
      conn = log_in_user(conn, user_fixture())
      conn = get(conn, Routes.contact_path(conn, :show, contact.id))

      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when data requested doesn't exist", %{conn: conn} do
      response =
        assert_error_sent 404, fn ->
          get(conn, Routes.contact_path(conn, :show, "f53b37df-e281-42f4-a4bd-b7d4c717e19e"))
        end

      assert {404, [_h | _t], "\"Not Found\""} = response
    end
  end

  describe "update contact" do
    setup [:create_contact]

    test "renders contact when data is valid", %{conn: conn, contact: %Contact{id: id} = contact} do
      conn = put(conn, Routes.contact_path(conn, :update, contact), contact: @update_attrs)
      assert %{"id" => ^id, "name" => name} = json_response(conn, 200)["data"]

      assert %{
               "id" => ^id,
               "name" => ^name,
               "phones" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, contact: contact} do
      conn = put(conn, Routes.contact_path(conn, :update, contact), contact: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders authorization error when data is invalid", %{conn: conn} do
      contact = contact_fixture()
      conn = put(conn, Routes.contact_path(conn, :update, contact), contact: @update_attrs)
      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when request session violates content policy", %{
      conn: conn,
      contact: contact
    } do
      conn = log_in_user(conn, user_fixture())
      conn = put(conn, Routes.contact_path(conn, :update, contact.id), contact: @update_attrs)

      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when data requested doesn't exist", %{conn: conn} do
      response =
        assert_error_sent 404, fn ->
          put(conn, Routes.contact_path(conn, :update, "f53b37df-e281-42f4-a4bd-b7d4c717e19e"),
            contact: @update_attrs
          )
        end

      assert {404, [_h | _t], "\"Not Found\""} = response
    end
  end

  describe "delete contact" do
    setup [:create_contact]

    test "deletes chosen contact", %{conn: conn, contact: contact} do
      conn = delete(conn, Routes.contact_path(conn, :delete, contact))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.contact_path(conn, :show, contact))
      end
    end

    test "renders authorization error when data is invalid", %{conn: conn} do
      contact = contact_fixture()
      conn = delete(conn, Routes.contact_path(conn, :delete, contact))
      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end

    test "renders errors when request session violates content policy", %{
      conn: conn,
      contact: contact
    } do
      conn = log_in_user(conn, user_fixture())
      conn = delete(conn, Routes.contact_path(conn, :delete, contact), contact: @update_attrs)

      assert json_response(conn, 404)["errors"] == ["Forbidden"]
    end
  end

  defp create_contact(%{user: user}) do
    {:ok, contact} = PhoneBook.Contacts.create_contact(Map.put(@create_attrs, :user_id, user.id))
    %{contact: contact}
  end
end
