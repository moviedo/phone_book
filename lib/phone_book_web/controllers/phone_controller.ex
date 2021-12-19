defmodule PhoneBookWeb.PhoneController do
  use PhoneBookWeb, :controller

  alias PhoneBook.Contacts
  alias PhoneBook.Contacts.{Contact, Phone}

  alias PhoneBookWeb.ContentPolicy

  action_fallback PhoneBookWeb.ApiFallbackController

  def index(conn, %{"contact_id" => contact_id}) do
    contact = Contacts.get_contact!(contact_id)

    with :ok <- Bodyguard.permit(ContentPolicy, :contact_policy, conn, contact),
         phones <- Contacts.list_phones(contact.id) do
      render(conn, "index.json", phones: phones)
    end
  end

  def create(conn, %{"phone" => phone_params, "contact_id" => contact_id}) do
    %Contact{user_id: user_id} = Contacts.get_contact!(contact_id)

    with :ok <-
           Bodyguard.permit(ContentPolicy, :contact_policy, conn, %Contact{user_id: user_id}),
         {:ok, %Phone{} = phone} <-
           Contacts.create_phone(Map.put(phone_params, "contact_id", contact_id)) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.contact_phone_path(conn, :show, contact_id, phone.id))
      |> render("show.json", phone: phone)
    end
  end

  def show(conn, %{"contact_id" => contact_id, "id" => id}) do
    phone = Contacts.get_phone!(id)
    attr = %{url_contact_id: contact_id, phone_contact_id: phone.contact_id}

    with :ok <- Bodyguard.permit(ContentPolicy, :phone_policy, conn, attr) do
      render(conn, "show.json", phone: phone)
    end
  end

  def update(conn, %{"contact_id" => contact_id, "id" => id, "phone" => phone_params}) do
    phone = Contacts.get_phone!(id)
    attr = %{url_contact_id: contact_id, phone_contact_id: phone.contact_id}

    with :ok <- Bodyguard.permit(ContentPolicy, :phone_policy, conn, attr),
         {:ok, %Phone{} = phone} <- Contacts.update_phone(phone, phone_params) do
      render(conn, "show.json", phone: phone)
    end
  end

  def delete(conn, %{"id" => id, "contact_id" => contact_id}) do
    phone = Contacts.get_phone!(id)
    attr = %{url_contact_id: contact_id, phone_contact_id: phone.contact_id}

    with :ok <- Bodyguard.permit(ContentPolicy, :phone_policy, conn, attr),
         {:ok, %Phone{}} <- Contacts.delete_phone(phone) do
      send_resp(conn, :no_content, "")
    end
  end
end
