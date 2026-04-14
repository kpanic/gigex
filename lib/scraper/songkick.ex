defmodule Gigex.Scraper.Songkick do
  @moduledoc """
  Scraper for songkick

  Songkick hosts concerts and festivals from all over the world.
  This scraper covers all the concerts and festivals in the Berliner area.

  NOTE: For the moment the list of events is very for each day.
  You could have a flood of events on the terminal.
  """

  @songkick "https://www.songkick.com"
  @songkick_berlin_url "#{@songkick}/metro-areas/28443-germany-berlin/"
  @default_entries_limit 10

  def get(opts \\ []) do
    limit = Keyword.get(opts, :limit, @default_entries_limit)

    @songkick_berlin_url
    |> http_get()
    |> Floki.parse_document!()
    |> Floki.find(".event-listings-element")
    |> Enum.reduce_while(
      {[], 0},
      fn
        _event, {entries, ^limit} ->
          {:halt, Enum.reverse(entries)}

        event, {entries, acc} ->
          raw_date = extract_date_from_event(event)
          raw_day = extract_day_of_the_week(event)

          date = normalize_date(raw_date)
          dotw = compute_dotw(date, raw_day)

          entry = %{
            name: extract_name(event),
            date: date,
            link: extract_event_link(event),
            location: extract_location(event),
            infos: extract_event_infos(event),
            datasource: "songkick",
            dotw: dotw
          }

          {:cont, {[entry | entries], acc + 1}}
      end
    )
  end

  defp extract_date_from_event(event) do
    datetime =
      event
      |> Floki.children()
      |> Floki.attribute("datetime")
      |> Floki.text()

    datetime
  end

  defp normalize_date(date) when is_binary(date) do
    case Date.from_iso8601(date) do
      {:ok, d} ->
        to_string(d)

      _ ->
        case DateTime.from_iso8601(date) do
          {:ok, dt, _} -> dt |> DateTime.to_date() |> to_string()
          _ -> nil
        end
    end
  end

  defp normalize_date(_), do: nil

  defp compute_dotw(date_iso, raw_day) do
    cond do
      is_binary(date_iso) and date_iso != "" ->
        case Date.from_iso8601(date_iso) do
          {:ok, d} ->
            ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            |> Enum.at(Date.day_of_week(d) - 1)

          _ ->
            nil
        end

      true ->
        raw_day
        |> to_string()
        |> String.replace(".", "")
        |> String.trim()
        |> String.downcase()
        |> songkick_day_map()
    end
  end

  defp songkick_day_map(day) do
    map = %{
      "mo" => "Monday",
      "mon" => "Monday",
      "monday" => "Monday",
      "di" => "Tuesday",
      "tu" => "Tuesday",
      "tue" => "Tuesday",
      "tuesday" => "Tuesday",
      "mi" => "Wednesday",
      "wed" => "Wednesday",
      "wednesday" => "Wednesday",
      "do" => "Thursday",
      "th" => "Thursday",
      "thu" => "Thursday",
      "thursday" => "Thursday",
      "fr" => "Friday",
      "fri" => "Friday",
      "friday" => "Friday",
      "sa" => "Saturday",
      "sat" => "Saturday",
      "saturday" => "Saturday",
      "so" => "Sunday",
      "sun" => "Sunday",
      "sunday" => "Sunday"
    }

    Map.get(map, day, String.capitalize(day))
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

  defp extract_day_of_the_week(event) do
    [human_date] = Floki.attribute(event, "title")

    human_date
    |> String.split()
    |> hd()
  end

  defp extract_event_link(event) do
    link =
      event
      |> Floki.find(".event-link")
      |> Floki.attribute("href")
      |> hd()

    "#{@songkick}#{link}"
  end

  defp extract_event_infos(event) do
    event_link = extract_event_link(event)

    # NOTE: Find out how to not hit too hard the website ;)
    # Cache?
    # For the moment `http_get/1` has a :timer.sleep of 200ms
    event_link
    |> http_get()
    |> Floki.parse_document!()
    |> Floki.find(".additional-details-container")
    |> Floki.text()
    # Trim surrounding blank space, `\n`, `\t`, etc.
    |> String.trim()
  end

  def http_get(url) do
    :timer.sleep(200)

    HTTPoison.get!(url,
      user_agent: "Gigex (Windows x64)",
      timeout: 10_000
    ).body
  end
end
