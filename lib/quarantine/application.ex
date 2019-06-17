defmodule Quarantine.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: :driver_supervisor},
      Quarantine.Server
    ]

    opts = [strategy: :one_for_one, name: Quarantine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
