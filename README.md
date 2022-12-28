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

# Usage examples


Take two gigs from the Songkick website:

```elixir
iex> Gigex.gigs(site: :songkick) |> Enum.take(3)
[
  %{
    datasource: "songkick",
    date: "2022-12-28",
    dotw: "Wednesday",
    infos: "Price: €32.50\n      Doors open: 19:00",
    link: "https://www.songkick.com/concerts/39461898-extrabreit-at-lido",
    location: "Lido, Berlin, Germany",
    name: "Extrabreit"
  },
  %{
    datasource: "songkick",
    date: "2022-12-28",
    dotw: "Wednesday",
    infos: "Price: €30.40 – €155.00\n      Doors open: 20:00For fans of: Pop and Rock.",
    link: "https://www.songkick.com/concerts/39365972-matthias-reim-at-mercedesbenz-arena",
    location: "Mercedes-Benz Arena, Berlin, Germany",
    name: "Matthias Reim"
  },
  %{
    datasource: "songkick",
    date: "2022-12-28",
    dotw: "Wednesday",
    infos: "",
    link: "https://www.songkick.com/concerts/40652712-btight-at-columbia-theater",
    location: "Columbia Theater, Berlin, Germany",
    name: "B-tight"
  }
]
```

Take two gigs from the Lido website:

```elixir
iex> Gigex.gigs(site: :lido) |> Enum.take(2)
[
  %{
    datasource: "lido",
    date: "2022-12-31",
    dotw: "Saturday",
    infos: "15,00 € Abendkasse, 12,00 € Vorverkauf+ Geb, Doors open: 23:55",
    link: "https://www.lido-berlin.de/events/2022-12-31-berlin-indie-night---silvester-2022",
    location: "Lido",
    name: "BERLIN INDIE NIGHT • SILVESTER 2022"
  },
  %{
    datasource: "lido",
    date: "2023-01-06",
    dotw: "Friday",
    infos: "10,00 € Vorverkauf+ Geb , 12,00 € Abendkasse, Doors open: 23:59",
    link: "https://www.lido-berlin.de/events/2023-01-06-the-early-days---let-s-dance-to-joy-division",
    location: "Lido",
    name: "THE EARLY DAYS • LET'S DANCE TO JOY DIVISION"
  }
]
```


Take five gigs from the Songkick and Lido website:

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
