defmodule Mailman do

  defrecord Email, 
    name: "", 
    subject: "", 
    from: "", 
    to: [], 
    cc: [], 
    bcc: [], 
    attachments: [],
    data: [],
    meta: []

  defrecord Envelope,
    parts: [
      html: "",
      plain: "",
      attachments: []
      ],
    subject: "",
    from: "",
    to: [],
    cc: [],
    bcc: []

  defrecord SmtpConfig, 
    relay: "", 
    username: "", 
    password: "", 
    port: 1111, 
    ssl: false, 
    tls: :never, 
    auth: :always

  defrecord TestConfig, 
    raise_errors: false

  defprotocol Mailer do
    def config(email)
  end

  defimpl Mailer, for: Email do
    def config(_) do
      raise "Please define implementation of Mailer protocol for Email record."
    end
  end

  defprotocol Adapter do
    def deliver(config, email)
  end

  defimpl Adapter, for: SmtpConfig do
    def deliver(config, email) do
      Mailman.ExternalSmtpAdapter.deliver(config, email)
    end
  end

  defimpl Adapter, for: TestConfig do
    def deliver(config, email) do
      Mailman.TestingAdapter.deliver(config, email)
    end
  end

  defprotocol Composer do
    def root_path(email)
  end

  defimpl Composer, for: Email do
    def root_path(_) do
      raise "Please implement protocol Mailman.Composer for Mailman.Email"
    end
  end

  @doc "Deliver given email"
  def deliver(email) when is_record(email, Email) do
    Mailer.config(email) |> 
      Adapter.deliver(email)
  end

  def start_smtp do
    :gen_smtp_server.start(:smtp_server_example, [[port: 1465]])
  end
end
