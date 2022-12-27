defmodule Gigex.Scraper.HTTP do
  @spec get(url :: binary()) :: html :: binary()
  def get(url) do
    # NOTE: Find out how to not hit too hard the website ;)
    # Cache?
    # For the moment `http_get/1` has a :timer.sleep of 200ms
    :timer.sleep(200)

    HTTPoison.get!(url,
      user_agent: "Gigex (Windows x64)",
      timeout: 10_000
    ).body
  end
end
