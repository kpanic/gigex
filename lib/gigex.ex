defmodule Gigex do
  @moduledoc """
  Gigex 🎸

  A scraper for gigs.

  ## Example

      iex> Gigex.get()
      [
        %{
          name: "The Cure",
          date: "2022-12-09",
          location: "Metropol"
        },
        %{
          name: "Led Zeppelin",
          date: "2022-12-10",
          location: "SO36"
        }
      ]
  """

  @spec get(url :: String.t()) :: concerts :: list()
  @doc """
  Get the latest jazz gigs from Songkick in Berlin

  ## Example

      iex> Gigex.get() |> Enum.take(5)
      [
        %{
          name: "Led Zeppelin",
          date: "2022-12-10",
          location: "SO36"
        },
        %{
          name: "The Cure",
          date: "2022-12-09",
          location: "Metropol"
        },
        %{
          name: "The all seeing I",
          date: "2022-12-12",
          location: "Earthsea"
        },
        %{
          name: "Kokoroko",
          date: "2022-12-14",
          location: "Tangeri"
        },
        %{
          name: "Dave Brubeck",
          date: "2022-12-15,
          location: "Blue Note"
        }
      ]
  """
  def get(url \\ "https://www.songkick.com/metro-areas/28443-germany-berlin/genre/jazz") do
    html =
      HTTPoison.get!(url,
        user_agent: "Gigex (Windows x64)",
        timeout: 10_000
      ).body

    html
    |> Floki.parse_document!()
    |> Floki.find(".event-listings-element")
    |> Enum.map(fn event ->
      %{
        name: extract_name(event),
        date: extract_date_from_event(event),
        location: extract_location(event)
      }
    end)
  end

  defp extract_date_from_event(event) do
    event
    |> Floki.attribute("title")
    |> Floki.text()
  end

  defp extract_location(event) do
    event
    |> Floki.find(".location")
    |> Floki.text()
    |> String.trim()
    |> String.replace(~r/[\n|\s]+/, " ")
  end

  defp extract_name(event) do
    event
    |> Floki.find(".artists")
    |> Floki.text()
  end
end
