defmodule PhoneBookWeb.ContentPolicy do
  @moduledoc """
  Implement access control policy for Contacts Context.
  """
  @behaviour Bodyguard.Policy

  alias PhoneBook.Contacts
  alias PhoneBook.Contacts.Contact

  # Users can show/create/update/delete their own contacts
  def authorize(:contact_policy, conn, %Contact{user_id: user_id}) do
    user = conn.assigns.current_user

    user.id == user_id
  end

  # Users can index/show/update/delete phones to their own contacts
  def authorize(:phone_policy, conn, %{
        url_contact_id: url_contact_id,
        phone_contact_id: phone_contact_id
      }) do
    contact = Contacts.get_contact!(phone_contact_id)

    contact.id == url_contact_id and authorize(:contact_policy, conn, contact)
  end

  # Catch all
  def authorize(_, _, _), do: {:error, :unauthorized}
end
