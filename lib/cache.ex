defmodule Gigex.Cache do
  @moduledoc """
  Cache for sites that we scrape

  The cache is cleaned up automatically after 2 hours.
  """

  @table_name :gigex_cache

  use GenServer

  @timer_interval :timer.hours(2)

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

  def init(_args) do
    @table_name = :ets.new(@table_name, [:named_table, :public])

    {:ok, %{ref: start_timer()}}
  end

  def handle_info(:cleanup, %{ref: ref}) do
    :ets.delete_all_objects(@table_name)
    new_ref = refresh_timer(ref)
    {:noreply, %{ref: new_ref}}
  end

  defp start_timer() do
    Process.send_after(self(), :cleanup, @timer_interval)
  end

  defp refresh_timer(ref) do
    Process.cancel_timer(ref)
    start_timer()
  end
end
