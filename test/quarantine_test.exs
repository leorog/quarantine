defmodule QuarantineTest do
  use ExUnit.Case
  doctest Quarantine

  test "it can check flags" do
    Quarantine.Server.start_link([some: [1, 2]])
    assert Quarantine.enabled?(:some, 1)
    refute Quarantine.enabled?(:some, 4)
    assert Quarantine.enabled?(:some, 2)
  end

  test "it can compute scores" do
    assert Quarantine.scores(:some, [1,2,3]) == [{1, 0.06948958571755551},
                                                 {2, 0.7655298695353627},
                                                 {3, 0.6601052872510872}]
  end
end
