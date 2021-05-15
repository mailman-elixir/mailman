# Creating emails

The email struct is defined as:

```elixir
defstruct subject: "", 
  from: "", 
  to: [], 
  cc: [], 
  bcc: [], 
  attachments: [], # This has to be %Mailman.Attachment{}. More about attachments below
  data: %{}, # This is the context for EEx. You put here data for your <%= %> placeholders
  html: "", # Actual html template
  text: "", # Actual plain template
  delivery: nil # If the message was created through parsing of the delivered email - this holds the 'Date' header
```


## CC and BCC
To instruct Mailman to actually send copies of your email to the listed CC and BCC recipients, use `Mailman.deliver(email, config, :send_cc_and_bcc)`. This, unfortunately, goes against the behaviour you are probably used to from end-user email apps, but reflects how SMTP servers work.

The `:cc`/`:bcc` fields only add corresponding *header lines* to the rendered email source. They do not, by themselves, magically effect delivery of actual copies to those recipients – they only change what's written on the envelope, so to speak. By default, Mailman will render the email struct and deliver it to the SMTP server only once, with a single set of recipients – those in the `:to` list. The `:send_cc_and_bcc` flag is a shortcut that will cause delivery of multiple emails at once. It returns a list of Tasks you can process.

If you need even more fine-grained control over CC/BCC mechanics, you will be best served by the lower-level `gen_smtp` functions, e.g.

```elixir
email_tuple = {
  from_address,
  [to_address],
  rendered_message,
}
result = :gen_smtp_client.send_blocking(email_tuple, %Mailman.SmtpConfig{...})
```

## Attachments

Mailman makes it easy to attach files, whether they're on your hard drive or on the internet.

The standard way to create an attachment is to use the `attach!` function:

```elixir
Mailman.Attachment.attach!(file_path_or_url, file_name \\ nil, mime_tuple \\ nil)
```
Use it when creating your email:
```elixir
attachments: [
  Mailman.Attachment.attach!("test/data/blank.png")
],
```

`file_path_or_url` can be an absolute file path, or one relative to the root of your project. You can also give it a URL, in which case Mailman will download the file for you before wrapping it in the Attachment struct.

`file_name` (optional) allows you to change the attachment's file name in the email.

`mime_tuple` (optional) allows you to set the MIME type of your file. This is rarely necessary, as Mailman can often infer this information from your file's extension and an included list of common MIME types. However, if that fails, you may specify the MIME type and subtype in a 2-tuple, e.g. `{"application", "vnd.openxmlformats-officedocument.wordprocessingml.document"}` for a docx file.

Note that the `attach!` option will throw an exception if it cannot open the file; use the `attach` function if you want to match on `{:ok, attachment}`, or `{:err, message}` instead.

#### Inline images
Emails can take inline content – typically, this is used for inlined images in the HTML part of the email. To add an inline image, first attach the file using the `inline!` function (instead of `attach!` – the arguments are the same). Then reference the image in your HTML body as follows:
```html
<img alt="foobar" src="cid:<%= URI.encode("your_filename.jpg") %>@mailman.attachment" />
```
The `cid:` prefix tells the email client that what follows is the `Content-ID` of an inlined attachment. The `@mailman.attachment` suffix is a meaningless dummy string (RFC 2392 requires Content IDs to look like email addresses).

## Adding extra headers

The `deliver` function takes an optional third parameter (or fourth, if you are using `:send_cc_and_bcc`) for that purpose:
```elixir
Mailman.deliver(your_email_struct, your_config, [{"X-Test-Header", "123"}])
```
