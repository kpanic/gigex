defmodule Gigex.Renderer do
  @moduledoc """
  Render *gigs* in different ways.
  """

  @spec render(gigs :: list(), opts :: Keyword.t()) :: map() | String.t()
  def render(gigs, opts) do
    opts
    |> Keyword.get(:renderer, :map)
    |> do_render(gigs)
  end

  defp do_render(:map, gigs), do: gigs
  defp do_render(:json, gigs), do: Jason.encode!(gigs, pretty: true)
end
