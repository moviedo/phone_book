defmodule PhoneBook.ContactsTest do
  use PhoneBook.DataCase

  alias PhoneBook.Accounts
  alias PhoneBook.Accounts.User

  alias PhoneBook.Contacts
  alias PhoneBook.Contacts.{Contact, Phone}
  import PhoneBook.ContactsFixtures

  describe "contacts" do
    @invalid_attrs %{name: nil, user_id: nil}

    test "list_contacts/1 returns all contacts" do
      contact = contact_fixture()
      assert Contacts.list_contacts(contact.user_id) == [contact]
    end

    test "get_contact!/1 returns the contact with given id" do
      contact = contact_fixture()
      assert Contacts.get_contact!(contact.id) == contact
    end

    test "create_contact/1 with valid data creates a contact" do
      contact_fix = contact_fixture()
      valid_attrs = %{name: "some name", user_id: contact_fix.user_id}

      assert {:ok, %Contact{} = contact} = Contacts.create_contact(valid_attrs)
      assert contact.name == "some name"
      assert contact.user_id == contact_fix.user_id
    end

    test "create_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contacts.create_contact(@invalid_attrs)
    end

    test "update_contact/2 with valid data updates the contact" do
      contact = contact_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Contact{} = contact} = Contacts.update_contact(contact, update_attrs)
      assert contact.name == "some updated name"
    end

    test "update_contact/2 with invalid data returns error changeset" do
      contact = contact_fixture()
      assert {:error, %Ecto.Changeset{}} = Contacts.update_contact(contact, @invalid_attrs)
      assert contact == Contacts.get_contact!(contact.id)
    end

    test "delete_contact/1 deletes the contact" do
      contact = contact_fixture()
      assert {:ok, %Contact{}} = Contacts.delete_contact(contact)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(contact.id) end
    end

    test "delete the contact when user is deleted" do
      contact = contact_fixture()
      user = Accounts.get_user!(contact.user_id)
      assert {:ok, %User{}} = Repo.delete(user)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(contact.id) end
    end

    test "change_contact/1 returns a contact changeset" do
      contact = contact_fixture()
      assert %Ecto.Changeset{} = Contacts.change_contact(contact)
    end
  end

  describe "phones" do
    @invalid_attrs %{number: nil, label: nil, contact_id: nil}

    test "list_phones/1 returns all phones" do
      phone = phone_fixture()
      assert Contacts.list_phones(phone.contact_id) == [phone]

      [contact] = Repo.all(from(c in Contact, where: c.id == ^phone.contact_id, preload: :phones))
      assert contact.phones == Contacts.list_phones(phone.contact_id)
    end

    test "get_phone!/1 returns the phone with given id" do
      phone = phone_fixture()
      assert Contacts.get_phone!(phone.id) == phone
    end

    test "create_phone/1 with valid data creates a phone" do
      phone = phone_fixture()
      valid_attrs = %{number: "+13475156777", label: "mobile", contact_id: phone.contact_id}

      assert {:ok, %Phone{} = phone} = Contacts.create_phone(valid_attrs)
      assert phone.number == valid_attrs.number
      assert phone.label == :mobile
      assert phone.contact_id == valid_attrs.contact_id
    end

    test "create_phone/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contacts.create_phone(@invalid_attrs)

      phone = phone_fixture()

      assert {:error, %Ecto.Changeset{} = changeset} =
               Contacts.create_phone(%{
                 number: "random",
                 label: :mobile,
                 contact_id: phone.contact_id
               })

      assert [number: _] = changeset.errors

      assert {:error, %Ecto.Changeset{} = changeset} =
               Contacts.create_phone(%{
                 number: "+13475156777",
                 label: "bad input",
                 contact_id: phone.contact_id
               })

      assert [label: _] = changeset.errors

      assert {:error, %Ecto.Changeset{} = changeset} =
               Contacts.create_phone(%{
                 number: "+13475156777",
                 label: :mobile,
                 contact_id: nil
               })

      assert [contact_id: _] = changeset.errors
    end

    test "update_phone/2 with valid data updates the phone" do
      phone = phone_fixture()
      update_attrs = %{number: "+13476127889", label: :home}

      assert {:ok, %Phone{} = updated_phone} = Contacts.update_phone(phone, update_attrs)
      assert updated_phone.number == update_attrs.number
      assert updated_phone.label == update_attrs.label
    end

    test "update_phone/2 with invalid data returns error changeset" do
      phone = phone_fixture()
      assert {:error, %Ecto.Changeset{}} = Contacts.update_phone(phone, @invalid_attrs)
      assert phone == Contacts.get_phone!(phone.id)
    end

    test "delete_phone/1 deletes the phone" do
      phone = phone_fixture()
      assert {:ok, %Phone{}} = Contacts.delete_phone(phone)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_phone!(phone.id) end
    end

    test "delete the phone when user is deleted" do
      phone = phone_fixture()
      contact = Contacts.get_contact!(phone.contact_id)
      user = Accounts.get_user!(contact.user_id)
      assert {:ok, %User{}} = Repo.delete(user)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_phone!(phone.id) end
    end

    test "delete the phone when contact is deleted" do
      phone = phone_fixture()
      contact = Contacts.get_contact!(phone.contact_id)
      assert {:ok, %Contact{}} = Repo.delete(contact)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_phone!(phone.id) end
    end

    test "change_phone/1 returns a phone changeset" do
      phone = phone_fixture()
      assert %Ecto.Changeset{} = Contacts.change_phone(phone)
    end
  end

  describe "contact with phone numbers" do
    test "get_phone!/1 returns the phone with given id" do
      phone = phone_fixture()
      [contact] = Repo.all(from(c in Contact, where: c.id == ^phone.contact_id, preload: :phones))

      assert Contacts.get_contact!(contact.id) == contact
      assert contact.phones == [phone]
    end
  end
end
