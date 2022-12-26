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
          entry = %{
            name: extract_name(event),
            date: extract_date_from_event(event),
            location: extract_location(event),
            dotw: extract_day_of_the_week(event),
            # event_details: extract_event_details(event),
            datasource: "songkick"
          }

          {:cont, {[entry | entries], acc + 1}}
      end
    )
  end

  # normalize()?

  defp extract_date_from_event(event) do
    datetime =
      event
      |> Floki.children()
      |> Floki.attribute("datetime")
      |> Floki.text()

    case DateTime.from_iso8601(datetime) do
      {:ok, datetime, _} ->
        datetime
        |> DateTime.to_date()
        |> to_string()

      _ ->
        datetime
    end
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

  # defp extract_event_details(event) do
  #   event_detail_url =
  #     event
  #     |> Floki.find(".event-link")
  #     |> Floki.attribute("href")
  #     |> hd()

  #   # NOTE: Find out how to not hit too hard the website ;)
  #   "#{@songkick}/#{event_detail_url}"
  #   |> http_get()
  #   |> Floki.parse_document!()
  #   |> Floki.find(".additional-details-container")
  #   |> Floki.text()
  # end

  def http_get(url) do
    :timer.sleep(200)

    HTTPoison.get!(url,
      user_agent: "Gigex (Windows x64)",
      timeout: 10_000
    ).body
  end
end
