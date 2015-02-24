defmodule Mailman.LocalServer do
  @behaviour :gen_smtp_server_session

  def init(hostname, session_count, address, options) do
    banner = ["#{hostname} ESMTP Local Mailman"]
    {:ok, banner, options}
  end

  def handle_HELO(hostname, state) do
    # IO.puts "HELO"
    {:ok, state}
  end

  def handle_EHLO(hostname, extensions, state) do
    # IO.puts "EHLO"
    {:ok, extensions, state}
  end

  def handle_MAIL(from, state) do
    # IO.puts "MAIL"
    {:ok, state}
  end

  def handle_MAIL_extension(extension, state) do
    # IO.puts "MAIL_extenstion"
    {:ok, state}
  end

  def handle_RCPT(to, state) do
    # IO.puts "RCPT"
    {:ok, state}
  end

  def handle_DATA(from, to, data, state) do
    # IO.puts "DATA"
    relay(from, to, data)
    {:ok, "1", state}
  end

  def handle_RSET(state) do
    # IO.puts "RSET"
    state
  end

  def handle_VRFY(address, state) do
    # IO.puts "VRFY"
    {:ok, "252 VRFY disabled by policy, just send some mail", state}
  end

  def handle_other(verb, args, state) do
    # IO.puts "OTHER: #{verb}"
    {["500 Error: command not recognized : '", verb, "'"], state}
  end

  def handle_AUTH(type, username, password, state) do
    # IO.puts "AUTH"
    {:ok, state}
  end

  def handle_STARTTLS(state) do
    # IO.puts "STARTTLS"
    state
  end

  def code_change(old, state, extra) do
    {:ok, state}
  end

  def terminate(reason, state) do
    {:ok, reason, state}
  end

  def relay(_, [], _) do
    :ok
  end

  def relay(from, [to|rest], data) do
    host = String.split(to, "@") |> List.last
    :gen_smtp_client.send {from, [to], String.to_char_list(data)}, [{:relay, host}]
    relay(from, rest, data)
  end

  def start(port) do
    :gen_smtp_server.start __MODULE__, 
      [[], [{:allow_bare_newlines, :true}, {:port, port}]]
  end
end
