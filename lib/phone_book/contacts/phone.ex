defmodule PhoneBook.Contacts.Phone do
  @moduledoc """
  Ecto Schema for phone table.
  """
  use Ecto.Schema
  import Ecto.Changeset

  require ExPhoneNumber

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
    |> foreign_key_constraint(:contact_id)
    |> validate_phone()
  end

  @doc """
  Validates the current phone number otherwise adds an error to the changeset.
  """
  def validate_phone(changeset) do
    number = get_field(changeset, :number)

    with {:ok, phone_number} <- ExPhoneNumber.parse(number, nil),
         true <- ExPhoneNumber.is_valid_number?(phone_number) do
      changeset
    else
      _ -> add_error(changeset, :number, "has invalid formatting, should be E164 formatted")
    end
  end
end
