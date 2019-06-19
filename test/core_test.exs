defmodule Quarantine.CoreTest do
  use ExUnit.Case

  alias Quarantine.Core

  test "score is consistent given the same input" do
    uuid = "34f64174-27e3-401a-9da5-b6ad238e0108"
    assert 0.8834973678187228 == Core.score(:feat1, uuid)
    refute 0.8834973678187228 == Core.score(:feat2, uuid)
    assert 0.9365529869535363 == Core.score(:feat1, "32")
    refute 0.9365529869535363 == Core.score(:feat2, "32")
  end

  test "on checking percentage toggle with uuid" do
    uuid = "34f64174-27e3-401a-9da5-b6ad238e0108"
    assert Core.enabled?(0.89, :feat1, uuid)
    refute Core.enabled?(0.88, :feat1, uuid)
  end

  test "on checking percentage toggle with integer" do
    assert Core.enabled?(0.94, :feat1, 32)
    refute Core.enabled?(0.93, :feat1, 32)
  end

  test "on checking whitelist toggle" do
    flag = ["some_id", "other_id"]
    assert Core.enabled?(flag, nil, "some_id")
    assert Core.enabled?(flag, nil, "other_id")
    refute Core.enabled?(flag, nil, "disabled")
  end
end
