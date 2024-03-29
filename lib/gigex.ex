defmodule Gigex do
  @moduledoc """
  Gigex 🎸

  A scraper for gigs.
  """

  @doc """
  Get the latest gigs from Songkick and Lido in Berlin

  ## Example

      iex> Gigex.gigs() |> Enum.take(5)
      [
        %{
          name: "Led Zeppelin",
          date: "2022-12-10",
          dotw: "Thursday",
          link: "https://www.lido-berlin.de/events/2022-12-10-led-zeppelin---so36",
          location: "SO36",
          infos: "15.00 € Abendkasse, 13.00 € Vorverkauf+ Geb , 11.00 € Early Bird+ Geb, Doors open: 20:00",
          datasource: "lido"
        },
        %{
          name: "The Cure",
          date: "2022-12-09",
          dotw: "Friday",
          link: "https://www.lido-berlin.de/events/2022-12-09-the-cure---metropol",
          infos: "15.00 € Abendkasse, 9.00 € Vorverkauf+ Geb , 7.00 € Early Bird+ Geb, Doors open 20:00",
          location: "Metropol",
          datasource: "songkick"
        },
        %{
          name: "The all seeing I",
          date: "2022-12-12",
          dotw: "Sunday",
          link: "https://www.lido-berlin.de/events/2022-12-12-the-all-seeing-i---earthsea",
          location: "Earthsea",
          infos: "",
          datasource: "lido"
        },
        %{
          name: "Kokoroko",
          date: "2022-12-14",
          dotw: "Wednesday",
          link: "https://www.lido-berlin.de/events/2022-12-14-kokokoko---tangeri",
          location: "Tangeri",
          infos: "Price: €51.00 – €72.00\n      Doors open: 20:00",
          datasource: "songkick"
        },
        %{
          name: "Dave Brubeck",
          date: "2022-12-15",
          dotw: "Saturday",
          link: "https://www.lido-berlin.de/events/2022-12-15-dave-brubeck---blue-note",
          location: "Blue Note",
          infos: "Price: €25.00 – €32.50\n      Doors open: 20:00",
          datasource: "songkick"
        }
      ]
  """
  @spec gigs(opts :: list()) :: concerts :: list()
  def gigs(opts \\ []) do
    {site, _} = Keyword.pop(opts, :site, :all)

    site
    |> Gigex.Scraper.run_for(opts)
    |> Gigex.Renderer.render(opts)
  end
end
