defmodule DataEncoding do
  require IEx

  def quoted_from(text) do
    align_quoted(code_quoted(text))
  end
  
  # Returns a string with a hex value based on given integer
  def int_to_hex_string(code) do
    integer_to_list(code, 16) |> to_string
  end

  def int_to_quoted_string(code) do
    cond do
      code == 61 -> "=3D"
      code == 9 || code == 10 || code == 13 || (code >= 32 && code <= 126 && code != 61) -> to_string([code])
      true -> "=#{int_to_hex_string(code)}"
    end
  end
  
  # Aligns a text to 76 charectars, ending lines with a soft break
  # using a '=' character followed by CRLF
  def align_quoted(text) do
    joiner = fn(str, [last, acc]) -> 
      line = cond  do
        last == "" -> str
        String.length(last) == 74 -> "=\n" <> str
        true -> "\n" <> str
      end
      joined = acc <> line
      [str, joined]
    end
    replace_last_spaces_and_tabs = fn(l) ->
      reversed = Enum.reverse(l) 
      [last_char | rest] = reversed
      cond do
         last_char == 32 -> to_string(Enum.reverse(rest)) <> "=20"
         last_char == 9  -> to_string(Enum.reverse(rest)) <> "=09"
         true      -> to_string(l)
      end
    end

    d = String.split(text, "\n")
    d = Enum.map(d, fn(l) -> String.to_char_list(l) end)

    d = Enum.map(d, fn(l) -> Enum.map(Enum.chunk(l, 74, 74, ''), fn(i) -> to_string(i) end) end)
      |> List.flatten |> Enum.map(fn(l) -> String.to_char_list(l) end)

    d = Enum.map d, replace_last_spaces_and_tabs

    Enum.reduce(d, ["",""], joiner)
      |> List.last
  end 

  # Replaces non ASCII characters with quoted alternatives
  def code_quoted(text) do
    list = :binary.bin_to_list(text)
    Enum.join (Enum.map list, fn(c) ->
      int_to_quoted_string(c)
    end)
  end

end
