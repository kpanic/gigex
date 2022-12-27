defmodule Gigex do
  @moduledoc """
  Gigex 🎸

  A scraper for gigs.
  """

  @doc """
  Get the latest gigs from Songkick in Berlin

  ## Example

      iex> Gigex.gigs() |> Enum.take(5)
      [
        %{
          name: "Led Zeppelin",
          date: "2022-12-10",
          dotw: "Thursday",
          link: "https://www.lido-berlin.de/events/2022-12-10-led-zeppelin---so36",
          location: "SO36",
          datasource: "lido"
        },
        %{
          name: "The Cure",
          date: "2022-12-09",
          dotw: "Friday",
          link: "https://www.lido-berlin.de/events/2022-12-09-the-cure---metropol",
          location: "Metropol",
          datasource: "songkick"
        },
        %{
          name: "The all seeing I",
          date: "2022-12-12",
          dotw: "Sunday",
          link: "https://www.lido-berlin.de/events/2022-12-12-the-all-seeing-i---earthsea",
          location: "Earthsea",
          datasource: "lido"
        },
        %{
          name: "Kokoroko",
          date: "2022-12-14",
          dotw: "Wednesday",
          link: "https://www.lido-berlin.de/events/2022-12-14-kokokoko---tangeri",
          location: "Tangeri",
          datasource: "songkick"
        },
        %{
          name: "Dave Brubeck",
          date: "2022-12-15",
          dotw: "Saturday",
          link: "https://www.lido-berlin.de/events/2022-12-15-dave-brubeck---blue-note",
          location: "Blue Note"
          datasource: "songkick"
        }
      ]
  """
  @spec gigs(opts :: list()) :: concerts :: list()
  def gigs(opts \\ []) do
    {site, _} = Keyword.pop(opts, :site, :all)
    Gigex.Scraper.run_for(site, opts)
  end
end
