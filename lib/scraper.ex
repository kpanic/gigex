defmodule Gigex.Scraper do
  @moduledoc """
  Main entry point to forward to different scrapers all the options to get gigs
  results back.
  """

  alias __MODULE__

  @spec run_for(site :: :all | :songkick | :lido, opts :: list()) :: concert :: list()
  def run_for(:all, opts) do
    # Get all the gigs from the scrapers and sort them by date so that they
    # appear like one stream of data.

    opts
    |> get_gigs_concurrently()
    |> Enum.sort_by(
      &Date.from_iso8601!(&1.date),
      Date
    )
  end

  def run_for(:songkick, opts), do: Scraper.Songkick.get(opts)
  def run_for(:lido, opts), do: Scraper.Lido.get(opts)

  defp get_gigs_concurrently(opts) do
    scrapers = [&Scraper.Songkick.get/1, &Scraper.Lido.get/1]

    scrapers
    |> Task.async_stream(
      fn scraper ->
        scraper.(opts)
      end,
      timeout: :timer.minutes(1)
    )
    |> Stream.flat_map(fn {:ok, result} ->
      result
    end)
    |> Enum.to_list()
  end
end
