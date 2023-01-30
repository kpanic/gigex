defmodule Gigex.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [Gigex.Cache]

    opts = [strategy: :one_for_one, name: Gigex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
