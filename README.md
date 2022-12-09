# Gigex 🎸

![A pleasant drawing of a sunburst bass guitar with violet, green and blue gradients](bass-guitar-drawing-640x480.png)

A scraper for gigs.

Currently supporting getting jazz concerts from Songkick in Berlin.


# Usage

```elixir
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
    date: "2022-12-15",
    location: "Blue Note"
  }
]
```
