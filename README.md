# Gigex 🎸 (A scraper for gigs)

![A pleasant drawing of a sunburst bass guitar with violet, green and blue gradients](bass-guitar-drawing-640x480.png)


Currently supporting getting concerts from Songkick (http://www.songkick.com)
and Lido in (https://www.lido-berlin.de) Berlin.

# Installation

The package can be installed by adding gigex to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    {:gigex, "~> 0.1"}
  ]
end
```

# Usage

```elixir
iex> Gigex.get() |> Enum.take(5)
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
     location: "Metropol",
     infos: "15.00 € Abendkasse, 9.00 € Vorverkauf+ Geb , 7.00 € Early Bird+ Geb, Doors open: 20:00",
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
```
