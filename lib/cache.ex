defmodule Gigex.Cache do
  @moduledoc """
  Cache for sites that we scrape

  The cache is cleaned up automatically after 2 hours.
  """

  @table_name :gigex_cache

  use GenServer

  @spec start_link(arg :: any()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_arg) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec get(key :: String.t()) :: content :: String.t()
  def get(key) do
    case :ets.lookup(@table_name, key) do
      [{_key, content}] ->
        content

      [] ->
        nil
    end
  end

  def put(key, content) do
    :ets.insert(@table_name, {key, content})
    content
  end

  def purge() do
    :ets.delete_all_objects(@table_name)
  end

  def init(_args) do
    @table_name = :ets.new(@table_name, [:named_table, :public])

    {:ok, []}
  end
end
