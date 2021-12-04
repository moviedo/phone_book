defmodule PhoneBook.Mailer do
  @moduledoc """
  This module defines the main interface to deliver e-mails.
  """

  use Swoosh.Mailer, otp_app: :phone_book
end
