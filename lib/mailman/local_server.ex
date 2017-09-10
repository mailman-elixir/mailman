defmodule Mailman.LocalServer do
  @moduledoc "Basic SMTP implementation via the gen_smtp_sever_session behavior. Implements relay'ing to external servers."
  @behaviour :gen_smtp_server_session

  def init(hostname, _session_count, _address, options) do
    banner = ["#{hostname} ESMTP Local Mailman"]
    {:ok, banner, options}
  end

  def handle_HELO(_hostname, state) do
    {:ok, state}
  end

  def handle_EHLO(_hostname, extensions, state) do
    {:ok, extensions, state}
  end

  def handle_MAIL(_from, state) do
    {:ok, state}
  end

  def handle_MAIL_extension(_extension, state) do
    {:ok, state}
  end

  def handle_RCPT(_to, state) do
    {:ok, state}
  end

  def handle_RCPT_extension(_to, state) do
    {:ok, state}
  end

  def handle_DATA(from, to, data, state) do
    relay(from, to, data)
    {:ok, "1", state}
  end

  def handle_RSET(state) do
    state
  end

  def handle_VRFY(_address, state) do
    {:ok, "252 VRFY disabled by policy, just send some mail", state}
  end

  def handle_other(verb, _args, state) do
    {["500 Error: command not recognized : '", verb, "'"], state}
  end

  def handle_AUTH(_type, _username, _password, state) do
    {:ok, state}
  end

  def handle_STARTTLS(state) do
    state
  end

  def code_change(_old, state, _extra) do
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
    :gen_smtp_client.send {from, [to], String.to_charlist(data)}, [{:relay, host}]
    relay(from, rest, data)
  end

  def start(port) do
    :gen_smtp_server.start __MODULE__,
      [[], [{:allow_bare_newlines, :true}, {:port, port}]]
  end
end
