defmodule PhoneBookWeb.PhoneView do
  use PhoneBookWeb, :view
  alias PhoneBookWeb.PhoneView

  def render("index.json", %{phones: phones}) do
    %{data: render_many(phones, PhoneView, "phone.json")}
  end

  def render("show.json", %{phone: phone}) do
    %{data: render_one(phone, PhoneView, "phone.json")}
  end

  def render("phone.json", %{phone: phone}) do
    %{
      id: phone.id,
      inserted_at: phone.inserted_at,
      number: phone.number,
      label: phone.label
    }
  end
end
