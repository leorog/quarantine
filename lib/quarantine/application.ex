defmodule Quarantine.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: :server_registry},
      Quarantine.Server
    ]

    opts = [strategy: :one_for_one, name: :quarantine_supervisor]
    Supervisor.start_link(children, opts)
  end
end
