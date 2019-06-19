defmodule QuarantineTest do
  use ExUnit.Case
  doctest Quarantine

  alias Quarantine.Server

  test "it can check flags" do
    {:ok, _} = GenServer.start_link(Server, %{f1: [1, 2, 3]}, name: :test)
    assert Quarantine.enabled?(:test, :f1, 1)
    refute Quarantine.enabled?(:test, :f1, 4)
    refute Quarantine.enabled?(:test, :f3, 1)
  end
end
