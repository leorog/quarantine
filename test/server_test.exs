defmodule Quarantine.ServerTest do
  use ExUnit.Case

  alias Quarantine.Server

  defmodule DummyDriver do
    @behaviour Quarantine.Driver

    def get_flags() do
      %{a: 0.5}
    end
  end

  test "init should dispatch :fetch message" do
    assert {:ok, :any} = Server.init(:any)
    assert_receive :fetch
  end

  test "it handle driver task results message" do
    assert {:noreply, %{a: 0.5}} = Server.handle_info({nil, %{a: 0.5}}, %{})
  end

  test "it handle driver task DOWN message" do
    state = %{}
    assert {:noreply, ^state} = Server.handle_info({:DOWN, nil, :process, nil, nil}, state)
  end

  test "if poll_interval and driver are present it starts the driver task and another :fetch" do
    state = %{poll_interval: 10, driver: DummyDriver}
    assert {:noreply, ^state} = Server.handle_info(:fetch, state)

    assert_receive {_ref, %{a: 0.5}}
    assert_receive {:DOWN, _ref, :process, _pid, :normal}
    assert_receive :fetch
  end

  test "it does not start driver task and another :fetch if poll_interval and driver are not present" do
    state = %{}
    assert {:noreply, ^state} = Server.handle_info(:fetch, state)

    refute_receive {_ref, _any}
    refute_receive {:DOWN, _ref, :process, _pid, :normal}
    refute_receive :fetch
  end

  test "it handle enabled? calls" do
    state = %{a: [1]}
    assert {:reply, true, ^state} = Server.handle_call({:enabled?, :a, 1}, nil, state)
    assert {:reply, false, ^state} = Server.handle_call({:enabled?, :b, 1}, nil, state)
  end

  test "on enabled? it lookup for quarantine process with caller pid precedence" do
    assert [{pid, _}] = Registry.lookup(:server_registry, :quarantine)
    assert %{included_applications: []} = :sys.get_state(pid)
    refute Quarantine.enabled?(:random, 1)

    Server.start_link(random: [1])

    assert [{pid, _}] = Registry.lookup(:server_registry, self())
    assert %{included_applications: [], random: [1]} = :sys.get_state(pid)
    assert Quarantine.enabled?(:random, 1)
  end
end
