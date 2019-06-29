defmodule Quarantine.Server do
  use GenServer

  def child_spec(args) do
    opts = [name: {:via, Registry, {:server_registry, :quarantine}}]
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [args, opts]},
      restart: :permanent,
    }
  end

  def start_link(args, opts \\ [name: {:via, Registry, {:server_registry, self()}}]) do
    state = merge_config(args)
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
    poll_interval = Map.get(state, :poll_interval)
    driver = Map.get(state, :driver)

    if poll_interval && driver do
      Process.send_after(self(), :fetch, poll_interval)
      send(self(), :update)
    end

    {:noreply, state}
  end

  def handle_info(:update, state) do
    new_flags = apply(state[:driver], :get_flags, [])
    {:noreply, Map.merge(state, new_flags)}
  rescue
    _ -> {:noreply, state}
  end

  def enabled?(feature, id) do
    message = {:enabled?, feature, id}
    case Registry.lookup(:server_registry, self()) do
      [{pid, _}] ->
        GenServer.call(pid, message)
      _ ->
        [{pid, _}] = Registry.lookup(:server_registry, :quarantine)
        GenServer.call(pid, message)
    end
  end

  defp get_feature(state, feature) do
    Map.get(state, feature, :unknown)
  end

  defp merge_config(args) do
    :quarantine
    |> Application.get_all_env()
    |> Keyword.merge(args)
    |> Enum.into(%{})
  end
end
