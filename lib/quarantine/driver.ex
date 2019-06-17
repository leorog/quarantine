defmodule Quarantine.Driver do
  @typep flag_name :: atom() | String.t

  @typep whitelist :: list(integer() | String.t)

  @callback get_flags() :: %{optional(flag_name) => whitelist | float()}
end
