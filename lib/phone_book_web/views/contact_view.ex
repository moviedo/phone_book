defmodule PhoneBookWeb.ContactView do
  use PhoneBookWeb, :view
  alias PhoneBookWeb.{ContactView, PhoneView}

  def render("index.json", %{contacts: contacts}) do
    %{data: render_many(contacts, ContactView, "contact.json")}
  end

  def render("show.json", %{contact: contact}) do
    %{data: render_one(contact, ContactView, "contact.json")}
  end

  def render("contact.json", %{contact: contact}) do
    phones = PhoneView.render("index.json", phones: contact.phones)

    %{
      id: contact.id,
      name: contact.name,
      phones: phones.data
    }
  end
end
