defmodule AttachmentsTest do
  use ExUnit.Case, async: true

  test "#inline returns { :ok, attachment } when file exists" do
    { :ok, attachment } = Mailman.Attachment.inline("test/data/blank.png")
    assert is_map(attachment)
  end

  test "#inline returns { :error, message } when file exists" do
    file_path = "test/data/idontexist.png"
    { :error, _ } = Mailman.Attachment.inline(file_path)
  end

  test "#mime_types returns the list of 646 types" do
    assert Enum.count(Mailman.Attachment.mime_types) == 646
  end

  test "#mime_type_for_path returns proper type" do
    assert Mailman.Attachment.mime_full_for_path("image.gif") == "image/gif"
    assert Mailman.Attachment.mime_full_for_path("image.png") == "image/png"
    assert Mailman.Attachment.mime_full_for_path("invoice.pdf") == "application/pdf"
  end

  test "#mime_type_for_path returns proepr values" do
    assert Mailman.Attachment.mime_type_for_path("image.gif") == "image"
    assert Mailman.Attachment.mime_type_for_path("image.png") == "image"
    assert Mailman.Attachment.mime_type_for_path("invoice.pdf") == "application"
  end

  test "#mime_subtype_for_path returns proepr values" do
    assert Mailman.Attachment.mime_sub_type_for_path("image.gif") == "gif"
    assert Mailman.Attachment.mime_sub_type_for_path("image.png") == "png"
    assert Mailman.Attachment.mime_sub_type_for_path("invoice.pdf") == "pdf"
  end
end
