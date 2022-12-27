defmodule Gigex.Scraper.Lido do
  @moduledoc """
  Scraper for Lido

  Lido is a dance club in Berlin, Germany
  It hosts various different concerts, partys and events.
  Website url: https://www.lido-berlin.de
  """

  @default_entries_limit 10
  @lido_url "https://www.lido-berlin.de"
  @location_name "Lido"

  @short_days_to_human_days %{
    "Mo" => "Monday",
    "Tu" => "Tuesday",
    "We" => "Wednesday",
    "Th" => "Thursday",
    "Fr" => "Friday",
    "Sa" => "Saturday",
    "Su" => "Sunday"
  }

  alias Gigex.Cache
  alias Gigex.Scraper.HTTP

  def get(opts \\ []) do
    case Cache.get(@lido_url) do
      nil ->
        @lido_url
        |> HTTP.get()
        |> gigs(opts)
        |> then(&Cache.put(@lido_url, &1))

      content ->
        content
    end
  end

  defp gigs(content, opts) do
    limit = Keyword.get(opts, :limit, @default_entries_limit)

    content
    |> Floki.parse_document!()
    |> Floki.find(".event-ticket")
    |> Enum.reduce_while(
      {[], 0},
      fn
        _event, {entries, ^limit} ->
          {:halt, Enum.reverse(entries)}

        event, {entries, acc} ->
          entry = %{
            name: extract_name(event),
            date: extract_date(event),
            location: @location_name,
            link: extract_event_link(event),
            dotw: extract_day_of_the_week(event),
            infos: extract_event_infos(event),
            # start_event: extract_entrance_hour(event),
            # end_event: "unknown",
            datasource: "lido"
          }

          {:cont, {[entry | entries], acc + 1}}
      end
    )
  end

  # NOTE: "data-realdate" it's in this format "2022-12-17 23:30:00 +0100"
  # We are interested only in the first part (i.e. 2022-12-17)
  defp extract_date(event) do
    [date_time] = Floki.attribute(event, "data-realdate")

    date_time
    |> String.split()
    |> hd()
  end

  defp extract_name(event) do
    event
    |> Floki.find(".event-ticket__content__title")
    |> Floki.text()
  end

  # Extract the day in short form (i.e. Th) and expand it to a human readable
  # day (i.e. Friday)
  defp extract_day_of_the_week(event) do
    event
    |> Floki.find(".event-ticket__meta__day")
    |> Floki.text()
    |> then(fn short_day ->
      Map.get(@short_days_to_human_days, short_day, short_day)
    end)
  end

  defp extract_event_link(event) do
    link =
      event
      |> Floki.find(".event-ticket__content__title")
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> hd()

    "#{@lido_url}#{link}"
  end

  defp extract_event_infos(event) do
    event_link = extract_event_link(event)

    event_infos =
      event_link
      |> HTTP.get()
      |> Floki.parse_document!()
      |> Floki.find(".price")
      |> Enum.map(fn info ->
        Floki.text(info)
      end)
      |> Enum.join(", ")
      |> String.trim()

    "#{event_infos}, Doors open: #{extract_entrance_hour(event)}"
  end

  # It returns the first entrance hour of the list, when the doors of the place
  # are open.
  # The second hour, usually matches with the open doors, since it's the start
  # of the event.
  # We ignore it for now since it's rare to have doors open not matching with
  # the start of the event.
  defp extract_entrance_hour(event) do
    event
    |> Floki.children()
    |> Floki.find(".event-ticket__meta__times__time__value")
    |> hd()
    |> Floki.text()
  end
end
