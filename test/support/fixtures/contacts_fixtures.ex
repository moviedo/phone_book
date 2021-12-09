defmodule PhoneBook.ContactsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhoneBook.Contacts` context.
  """
  import PhoneBook.AccountsFixtures

  @doc """
  Generate a contact.
  """
  def contact_fixture(attrs \\ %{}, user_attr \\ %{}) do
    user = user_fixture(user_attr)

    {:ok, contact} =
      attrs
      |> Enum.into(%{
        name: "some name",
        user_id: user.id
      })
      |> PhoneBook.Contacts.create_contact()

    contact
  end

  @doc """
  Generate a phone.
  """
  def phone_fixture(attrs \\ %{}, contact_attr \\ %{}, user_attr \\ %{}) do
    contact = contact_fixture(contact_attr, user_attr)

    {:ok, phone} =
      attrs
      |> Enum.into(%{
        number: "+17182347788",
        label: :mobile,
        contact_id: contact.id
      })
      |> PhoneBook.Contacts.create_phone()

    phone
  end
end
