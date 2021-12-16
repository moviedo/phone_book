defmodule PhoneBookWeb.ContentPolicy do
  @moduledoc """
  Implement access control policy for Contacts Context.
  """
  @behaviour Bodyguard.Policy

  alias PhoneBook.Accounts.User
  alias PhoneBook.Contacts.{Contact, Phone}

  # Users can show/update/delete their own contacts
  def authorize(:contact_policy, conn, %Contact{user_id: user_id}) do
    user = conn.assigns.current_user

    user.id == user_id
  end

  # Catch all
  def authorize(_, _, _), do: {:error, :unauthorized}
end
