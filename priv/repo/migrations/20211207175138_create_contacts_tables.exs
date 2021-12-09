defmodule PhoneBook.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:contacts, [:user_id])

    create table(:phones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :number, :string
      add :label, :string

      add :contact_id, references(:contacts, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create index(:phones, [:contact_id])
  end
end
