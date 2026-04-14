defmodule Gigex.Scraper do
  @moduledoc """
  Main entry point to forward to different scrapers all the options to get gigs
  results back.
  """

  alias __MODULE__

  @spec run_for(site :: :all | :songkick | :lido | :jazzity, opts :: list()) :: concert :: list()
  def run_for(:all, opts) do
    # Get all the gigs from the scrapers and sort them by date so that they
    # appear like one stream of data.

    Enum.sort_by(
      Scraper.Songkick.get(opts) ++ Scraper.Lido.get(opts) ++ Scraper.Jazzity.get(opts),
      fn item ->
        case Map.get(item, :date) || Map.get(item, "date") do
          nil ->
            Date.utc_today()

          date when is_binary(date) ->
            case Date.from_iso8601(date) do
              {:ok, d} -> d
              _ -> Date.utc_today()
            end

          %Date{} = d ->
            d

          _ ->
            Date.utc_today()
        end
      end,
      Date
    )
  end

  def run_for(:songkick, opts), do: Scraper.Songkick.get(opts)
  def run_for(:lido, opts), do: Scraper.Lido.get(opts)
  def run_for(:jazzity, opts), do: Scraper.Jazzity.get(opts)
end
