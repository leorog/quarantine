defmodule Quarantine.Server do
  use GenServer

  def start_link(args \\ [], opts \\ [name: __MODULE__]) do
    state =
      :quarantine
      |> Application.get_all_env()
      |> Keyword.merge(args)
      |> Enum.into(%{})

    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    send(self(), :fetch)
    {:ok, state}
  end

  def handle_call({:enabled?, feature, id}, _from, state) do
    config = get_feature(state, feature)
    enabled? = Quarantine.Core.enabled?(config, feature, id)

    {:reply, enabled?, state}
  end

  def handle_info(:fetch, state) do
    pool_interval = Map.get(state, :pool_interval)
    driver = Map.get(state, :driver)

    if pool_interval && driver do
      Process.send_after(self(), :fetch, pool_interval)
      Task.Supervisor.async_nolink(:driver_supervisor, driver, :get_flags, [])
    end

    {:noreply, state}
  end

  def handle_info({_ref, new_flags}, state) do
    {:noreply, Map.merge(state, new_flags)}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    {:noreply, state}
  end

  defp get_feature(state, feature) do
    Map.get(state, feature, :unknown)
  end
end
