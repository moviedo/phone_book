# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PhoneBook.Repo.insert!(%PhoneBook.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias PhoneBook.{Accounts, Contacts}

alias Faker.Phone.EnUs

defmodule FakeData do
  def valid_phone() do
    number = "+1#{EnUs.area_code()}#{EnUs.subscriber_number(7)}"

    with {:ok, phone_number} <- ExPhoneNumber.parse(number, nil),
         true <- ExPhoneNumber.is_valid_number?(phone_number) do
      ExPhoneNumber.format(phone_number, :e164)
    else
      _ -> valid_phone()
    end
  end
end

{:ok, user} = Accounts.register_user(%{
  email: "user1@test.com",
  password: "User1234!"
})

Enum.each(1..5, fn _ ->
  {:ok, contact} = Contacts.create_contact(%{
    name: Faker.Person.name(),
    user_id: user.id
  })

  Enum.each(1..2, fn _ -> 

      Contacts.create_phone(%{
        number: FakeData.valid_phone(),
        label: :mobile,
        contact_id: contact.id
      })
  end)
end)