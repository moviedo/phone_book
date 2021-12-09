defmodule PhoneBook.Contacts.Phone do
  @moduledoc """
  Ecto Schema for phone table.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "phones" do
    field :number, :string
    field :label, Ecto.Enum, values: [:mobile, :home, :work, :other]
    belongs_to :contact, PhoneBook.Contacts.Contact

    timestamps()
  end

  @doc false
  def changeset(phone, attrs) do
    phone
    |> cast(attrs, [:number, :label, :contact_id])
    |> validate_required([:number, :label, :contact_id])
  end
end
