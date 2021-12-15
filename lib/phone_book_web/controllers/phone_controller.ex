defmodule PhoneBookWeb.PhoneController do
  use PhoneBookWeb, :controller

  alias PhoneBook.Contacts
  alias PhoneBook.Contacts.Phone

  action_fallback PhoneBookWeb.ApiFallbackController

  def index(conn, %{"contact_id" => contact_id}) do
    phones = Contacts.list_phones(contact_id)
    render(conn, "index.json", phones: phones)
  end

  def create(conn, %{"phone" => phone_params, "contact_id" => contact_id}) do
    with {:ok, %Phone{} = phone} <-
           Contacts.create_phone(Map.put(phone_params, "contact_id", contact_id)) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.contact_phone_path(conn, :show, contact_id, phone.id))
      |> render("show.json", phone: phone)
    end
  end

  def show(conn, %{"contact_id" => contact_id, "id" => id}) do
    with phone <- Contacts.get_phone!(id),
         true <- phone.contact_id == contact_id do
      render(conn, "show.json", phone: phone)
    end
  end

  def update(conn, %{"contact_id" => contact_id, "id" => id, "phone" => phone_params}) do
    phone = Contacts.get_phone!(id)

    with true <- phone.contact_id == contact_id,
         {:ok, %Phone{} = phone} <- Contacts.update_phone(phone, phone_params) do
      render(conn, "show.json", phone: phone)
    end
  end

  def delete(conn, %{"id" => id, "contact_id" => contact_id}) do
    phone = Contacts.get_phone!(id)

    with true <- phone.contact_id == contact_id,
         {:ok, %Phone{}} <- Contacts.delete_phone(phone) do
      send_resp(conn, :no_content, "")
    end
  end
end
