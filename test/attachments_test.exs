defmodule AttachmentsTest do
  use ExUnit.Case, async: true

  test "#inline returns { :ok, attachment } when file exists" do
    {:ok, attachment} = Mailman.Attachment.inline("test/data/blank.png")
    assert is_map(attachment)
  end

  test "Attachment via HTTPoison works" do
    {:ok, attachment} = Mailman.Attachment.inline("https://www.w3.org/")
    assert is_map(attachment)
  end


  test "#inline returns {:error, message} when file doesn't exist" do
    file_path = "test/data/idontexist.png"
    {:error, _} = Mailman.Attachment.inline(file_path)
  end

  test "Attachment with a different disposition filename" do
    {:ok, attachment} = Mailman.Attachment.inline("test/data/blank.png", "another_name.png")
    assert attachment.file_name == "another_name.png"
    assert is_map(attachment)
  end

  test "Attachment with a manually set mime type" do
    {:ok, attachment} = Mailman.Attachment.attach("test/data/blank.png", nil, {"image", "gif"})
    assert attachment.mime_type == "image"
    assert attachment.mime_sub_type == "gif"
    assert is_map(attachment)
  end

  test "#mime_types returns the list of 648 types" do
    assert Enum.count(Mailman.Attachment.mime_types()) == 648
  end

  test "mime type getter returns proper type" do
    assert Mailman.Attachment.mime_type_and_subtype_from_extension("image.gif") ==
             {"image", "gif"}

    assert Mailman.Attachment.mime_type_and_subtype_from_extension("image.png") ==
             {"image", "png"}

    assert Mailman.Attachment.mime_type_and_subtype_from_extension("invoice.pdf") ==
             {"application", "pdf"}

    assert Mailman.Attachment.mime_type_and_subtype_from_extension("file.strange") ==
             {"application", "octet-stream"}

    assert Mailman.Attachment.mime_type_and_subtype_from_extension("settings.mobileconfig") ==
             {"application", "x-apple-aspen-config"}
  end
end
