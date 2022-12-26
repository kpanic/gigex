defmodule Gigex.Scraper do
  alias __MODULE__

  @spec run_for(site :: atom()) :: concert :: list()
  def run_for(:all) do
    Enum.sort_by(
      Scraper.Songkick.get() ++ Scraper.Lido.get(),
      &Date.from_iso8601!(&1.date),
      Date
    )
  end

  def run_for(:songkick), do: Scraper.Songkick.get()
  def run_for(:lido), do: Scraper.Lido.get()
end
