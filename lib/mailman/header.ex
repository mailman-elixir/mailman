defmodule Mailman.Header do
  @moduledoc "Represents a Mime-Mail header"

  defstruct name: "",
            value: ""

  def from_raw(raw) when is_tuple(raw) do
    %Mailman.Header{
      name: elem(raw, 0),
      value: process_value(elem(raw, 0), elem(raw, 1))
    }
  end

  def process_value(name, value) do
    case name do
      'To' -> String.split(value, ",")
      _ -> value
    end
  end
end
