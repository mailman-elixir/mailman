defmodule Mailman.Context do
  @moduledoc "Defines the configuration for both rendering and sending of messages"
 
  defstruct config: %Mailman.TestConfig{}, composer: %Mailman.EexComposeConfig{}
end
