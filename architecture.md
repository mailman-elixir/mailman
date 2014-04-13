## Mailman module

Email:
  - name :: string
  - subject :: string
  - from :: string
  - to :: [ string ]
  - cc :: [ string ]
  - bcc :: [ string ]
  - attachments :: [ file ]

SmtpConfig:
  - relay :: string
  - username :: string
  - password :: string
  - port :: integer
  - ssl :: bool
  - tls :: atom
  - auth :: atom

TestConfig:
  - raise_errors :: bool

protocol Mailer
  - deliver(email) :: (atom, string)
  - config(email) :: config

## Mailman.Email module

Responsible for:
* Rendering of emails into sendable data

- render(email) :: { string, [string], string

#### 

