defmodule PhoneBook.Repo do
  use Ecto.Repo,
    otp_app: :phone_book,
    adapter: Ecto.Adapters.Postgres
end
