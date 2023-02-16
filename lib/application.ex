defmodule Gigex.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [Gigex.Cache]

    opts = [strategy: :one_for_one, name: Gigex.Supervisor]
    result = Supervisor.start_link(children, opts)

    if is_cli_mode?() do
      Gigex.CLI.main()

      System.halt(0)
    end

    result
  end

  defp is_cli_mode?(), do: System.get_env("GIGEX_MODE") == "CLI"
end
