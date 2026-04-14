defmodule Gigex.Scraper.Jazzity do
  @moduledoc """
  Scraper for https://jazzity.net/prog.php that extracts concert listings.

  Usage:
    Gigex.Scraper.Jazzity.fetch()

  Returns {:ok, events} or {:error, reason}.
  Each event is a map with :title, :venue, :date, :time, :url, :description when available.
  """

  require Logger

  @default_url "https://jazzity.net/prog.php"

  @doc "Fetch and parse concerts from the given URL (defaults to site prog page)."
  def fetch(url \\ @default_url) when is_binary(url) do
    case HTTPoison.get(url, [], follow_redirect: true, recv_timeout: 15_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse(body, url)

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, {:http_status, code}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse(body, base_url) do
    case Floki.parse_document(body) do
      {:ok, doc} ->
        nodes = extract_nodes(doc)
        events = Enum.map(nodes, &node_to_event(&1, base_url))

        {:ok,
         Enum.reject(events, fn e ->
           (Map.get(e, :name, "") == "" or is_nil(Map.get(e, :name))) and
             is_nil(Map.get(e, :link))
         end)}

      {:error, err} ->
        {:error, {:parse_error, err}}
    end
  end

  # Find candidate nodes then filter by content heuristics (time, image, clubs link, month names)
  defp extract_nodes(doc) do
    # Prefer the programme rows used on jazzity: div.row.prog_list contains a single event each
    rows = Floki.find(doc, "div.row.prog_list")
    rows = if rows == [], do: Floki.find(doc, ".prog_list"), else: rows

    if rows != [] do
      rows
    else
      selectors = ["article", ".prog", ".program", ".event", ".post", "li", "div"]

      found =
        selectors
        |> Enum.map(&Floki.find(doc, &1))
        |> Enum.find(fn nodes -> nodes != [] end)

      candidates =
        case found do
          nil ->
            Floki.find(doc, "a")
            |> Enum.filter(fn n -> String.trim(Floki.text(n || "")) != "" end)

          nodes ->
            nodes
        end

      Enum.filter(candidates, fn node ->
        text = Floki.text(node) |> to_string() |> String.replace(~r/\s+/, " ") |> String.trim()
        hrefs = Floki.attribute(node, "href")

        cond do
          text =~ ~r/\b\d{1,2}:\d{2}\b/ ->
            true

          Enum.any?(hrefs, &String.contains?(&1, "clubs.php")) ->
            true

          String.contains?(text, "/img/") ->
            true

          text =~
              ~r/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|Januar|Februar|März|April|Mai|Juni|Juli|August|September|Oktober|November|Dezember)/i ->
            true

          true ->
            false
        end
      end)
    end
  end

  defp node_to_event(node, base_url) do
    # Raw text and split lines for heuristics
    raw = Floki.raw_html(node) |> to_string()
    text = Floki.text(node) |> to_string() |> String.replace(~r/\s+/, " ") |> String.trim()

    lines =
      text
      |> String.split(~r/\s{2,}|\n/)
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    time =
      case Regex.run(~r/\b\d{1,2}:\d{2}\b/, text) do
        nil -> nil
        [m | _] -> m
      end

    date = parse_date(text, lines)

    # Collect anchors: {href, text}
    anchors =
      Floki.find(node, "a")
      |> Enum.map(fn a ->
        {Floki.attribute(a, "href") |> List.first(), Floki.text(a) |> String.trim()}
      end)

    # Prefer external hrefs, then club links, then first anchor
    external =
      Enum.find(anchors, fn {h, _} -> is_binary(h) and String.starts_with?(h, "http") end)

    club = Enum.find(anchors, fn {h, _} -> is_binary(h) and String.contains?(h, "clubs.php") end)
    first_anchor = List.first(anchors)

    href =
      (external && elem(external, 0)) || (club && elem(club, 0)) ||
        (first_anchor && elem(first_anchor, 0))

    url = if href, do: build_absolute_url(base_url, href), else: nil

    # Location: prefer explicit club anchor text (a[href*='clubs.php']), else fallback to first short font-size anchor
    club_node = Floki.find(node, "a[href*='clubs.php']") |> List.first()

    location =
      if club_node do
        # try to get the small-font child (club name) inside the anchor, else full anchor text
        Floki.find(club_node, "[style*='font-size:1.0em']")
        |> Enum.map(&Floki.text/1)
        |> List.first()
        |> case do
          nil -> Floki.text(club_node)
          v -> v
        end
      else
        Floki.find(node, "[style*='font-size:1.0em'] a")
        |> Enum.map(&Floki.text/1)
        |> Enum.find(fn t -> t && String.length(String.trim(t)) > 1 end)
      end

    location = (location || "") |> to_string() |> String.trim()

    # Name: prefer an anchor with substantial text that is not the club/tag link
    name_anchor =
      Enum.find(anchors, fn {h, t} ->
        (t && String.length(t) > 6) and not (is_binary(h) and String.contains?(h, "clubs.php")) and
          not (is_binary(h) and String.contains?(h, "tags.php"))
      end)

    name =
      cond do
        name_anchor ->
          elem(name_anchor, 1)

        true ->
          # fallback: look for styled title elements (font-size:1.4em)
          Floki.find(node, "[style*='font-size:1.4em']")
          |> Enum.map(&Floki.text/1)
          |> Enum.find(fn t -> t && String.length(String.trim(t)) > 3 end)
      end

    name = (name || "") |> String.trim()

    # Infos: try to pick the descriptive block (font-size:1.0em) excluding the club/name lines
    desc_candidates =
      Floki.find(node, "[style*='font-size:1.0em']")
      |> Enum.map(&Floki.text/1)
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == "" or &1 == location or &1 == name))

    infos =
      Enum.find(desc_candidates, fn d -> String.length(d) > 20 end) ||
        lines
        |> Enum.reject(fn l ->
          l == name or l == location or Regex.match?(~r/^\d{1,2}:\d{2}$/, l) or
            Regex.match?(~r/^\d{1,2}$/, l)
        end)
        |> Enum.join(" | ")
        |> String.trim()

    # dotw from date if possible
    dotw =
      case date do
        nil ->
          nil

        iso when is_binary(iso) ->
          case Date.from_iso8601(iso) do
            {:ok, d} ->
              ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
              |> Enum.at(Date.day_of_week(d) - 1)

            _ ->
              nil
          end

        _ ->
          nil
      end

    %{
      name: name,
      date: date,
      link: url,
      location: location,
      infos: infos,
      datasource: "jazzity",
      dotw: dotw
    }
  end

  defp find_first_anchor_href(node) do
    case Floki.find(node, "a") do
      [{_, attrs, _} | _] ->
        case List.keyfind(attrs, "href", 0) do
          {"href", v} -> v
          _ -> nil
        end

      _ ->
        nil
    end
  end

  defp parse_date(text, lines) do
    # Normalize whitespace
    t = String.replace(text || "", ~r/\s+/, " ") |> String.trim()

    # month name mapping (english and german short/long)
    months = %{
      "jan" => 1,
      "january" => 1,
      "januar" => 1,
      "feb" => 2,
      "february" => 2,
      "februar" => 2,
      "mar" => 3,
      "march" => 3,
      "märz" => 3,
      "maerz" => 3,
      "apr" => 4,
      "april" => 4,
      "may" => 5,
      "mai" => 5,
      "jun" => 6,
      "june" => 6,
      "juni" => 6,
      "jul" => 7,
      "july" => 7,
      "juli" => 7,
      "aug" => 8,
      "august" => 8,
      "sep" => 9,
      "sept" => 9,
      "september" => 9,
      "oct" => 10,
      "october" => 10,
      "oktober" => 10,
      "nov" => 11,
      "november" => 11,
      "dec" => 12,
      "december" => 12,
      "dezember" => 12
    }

    # Try several patterns: day month year (e.g., 14 April 2026)
    patterns = [
      ~r/(\d{1,2})\s+(January|Jan|Januar|Februar|Feb|März|Mar|Maerz|April|Apr|Mai|May|Juni|Jun|Juli|Jul|August|Aug|September|Sep|Oktober|Oct|November|Nov|Dezember|Dec)\s+(\d{4})/i,
      ~r/(January|Jan|Januar|Februar|Feb|März|Mar|Maerz|April|Apr|Mai|May|Juni|Jun|Juli|Jul|August|Aug|September|Sep|Oktober|Oct|November|Nov|Dezember|Dec)\s+(\d{1,2}),?\s*(\d{4})/i,
      ~r/(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+(\d{4})/i
    ]

    Enum.reduce_while(patterns, nil, fn pat, _acc ->
      case Regex.run(pat, t) do
        nil ->
          {:cont, nil}

        [_, a, b, c] ->
          # patterns may return day, month, year in different order
          {day, month_name, year} =
            if Regex.match?(~r/^\d{1,2}$/, a) do
              {String.to_integer(a), b, c}
            else
              {String.to_integer(b), a, c}
            end

          mon = String.downcase(String.replace(month_name, "ä", "ae"))
          mon_key = String.slice(mon, 0..2)
          month = Map.get(months, mon_key) || Map.get(months, mon)

          if month do
            iso =
              "#{year}-#{String.pad_leading(Integer.to_string(month), 2, "0")}-#{String.pad_leading(Integer.to_string(day), 2, "0")}"

            {:halt, iso}
          else
            {:cont, nil}
          end
      end
    end)
    |> case do
      nil ->
        # try to detect day and month split across lines (e.g., "14" and "April 2026")
        idx_day = Enum.find_index(lines, fn l -> Regex.match?(~r/^\d{1,2}$/, l) end)

        if idx_day do
          day = Enum.at(lines, idx_day) |> String.trim()
          next = Enum.at(lines, idx_day + 1) || ""

          case Regex.run(
                 ~r/(January|Jan|Januar|Februar|Feb|März|Mar|Maerz|April|Apr|Mai|May|Juni|Jun|Juli|Jul|August|Aug|September|Sep|Oktober|Oct|November|Nov|Dezember|Dec)\s*(\d{4})?/i,
                 next
               ) do
            nil ->
              nil

            [_, m, y] ->
              mon = String.downcase(String.replace(m, "ä", "ae"))
              mon_key = String.slice(mon, 0..2)
              month = Map.get(months, mon_key) || Map.get(months, mon)
              year = if y in [nil, ""], do: Date.utc_today().year |> Integer.to_string(), else: y

              if month do
                "#{year}-#{String.pad_leading(Integer.to_string(month), 2, "0")}-#{String.pad_leading(day, 2, "0")}"
              else
                nil
              end
          end
        else
          nil
        end

      iso ->
        iso
    end
  end

  defp build_absolute_url(base, href) when is_binary(href) do
    try do
      case URI.parse(href) do
        %URI{scheme: nil} -> URI.merge(base, href) |> to_string()
        _ -> href
      end
    rescue
      _ -> href
    end
  end

  @doc "Return list of events (wrapper for fetch)."
  def get(_opts \\ []) do
    case fetch() do
      {:ok, events} -> events
      {:error, _} -> []
    end
  end
end
