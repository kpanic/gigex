defmodule Gigex.Scraper.HTTP do
  @spec get(url :: binary()) :: html :: binary()
  def get(url) do
    HTTPoison.get!(url,
      user_agent: "Gigex (Windows x64)",
      timeout: 10_000
    ).body
  end
end
