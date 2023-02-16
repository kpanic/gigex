defmodule Gigex.CLI do
  def main(_args \\ []) do
    [renderer: :json]
    |> Gigex.gigs()
    |> IO.puts()
  end
end
