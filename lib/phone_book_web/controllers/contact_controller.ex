defmodule PhoneBookWeb.ContactController do
  use PhoneBookWeb, :controller

  alias PhoneBook.Contacts
  alias PhoneBook.Contacts.Contact

  action_fallback PhoneBookWeb.ApiFallbackController

  def index(conn, _params) do
    user = conn.assigns.current_user
    contacts = Contacts.list_contacts(user.id)
    render(conn, "index.json", contacts: contacts)
  end

  def create(conn, %{"contact" => contact_params}) do
    user = conn.assigns.current_user
    contact_params = Map.put(contact_params, "user_id", user.id)

    with {:ok, %Contact{} = contact} <- Contacts.create_contact(contact_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.contact_path(conn, :show, contact))
      |> render("show.json", contact: contact)
    end
  end

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    with contact <- Contacts.get_contact!(id),
         true <- user.id == contact.user_id do
      render(conn, "show.json", contact: contact)
    end
  end

  def update(conn, %{"id" => id, "contact" => contact_params}) do
    user = conn.assigns.current_user
    contact = Contacts.get_contact!(id)

    with true <- user.id == contact.user_id,
         {:ok, %Contact{} = contact} <- Contacts.update_contact(contact, contact_params) do
      render(conn, "show.json", contact: contact)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    contact = Contacts.get_contact!(id)

    with true <- user.id == contact.user_id,
         {:ok, %Contact{}} <- Contacts.delete_contact(contact) do
      send_resp(conn, :no_content, "")
    end
  end
end
