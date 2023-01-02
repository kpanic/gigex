defmodule Gigex.Server do
  alias Gigex.Cache

  use GenServer

  @timer_interval :timer.hours(2)

  @spec start_link(arg :: any()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_arg) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init(_args) do
    {:ok, %{ref: nil}, {:continue, :get_gigs}}
  end

  @impl GenServer
  def handle_continue(:get_gigs, state) do
    Gigex.gigs()
    ref = start_timer()

    {:noreply, %{state | ref: ref}}
  end

  @impl GenServer
  def handle_info(:refresh_cache, %{ref: ref} = state) do
    Cache.purge()

    Gigex.gigs()
    new_ref = refresh_timer(ref)
    {:noreply, %{state | ref: new_ref}}
  end

  defp start_timer() do
    Process.send_after(self(), :refresh_cache, @timer_interval)
  end

  defp refresh_timer(ref) do
    Process.cancel_timer(ref)
    start_timer()
  end
end
