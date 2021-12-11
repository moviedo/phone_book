defmodule PhoneBook.Contacts.Contact do
  @moduledoc """
  Ecto Schema for contact table.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contacts" do
    field :name, :string
    belongs_to :user, PhoneBook.Accounts.User
    has_many :phones, PhoneBook.Contacts.Phone

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
  end
end
