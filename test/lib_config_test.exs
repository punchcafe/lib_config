defmodule LibConfigTest do
  use ExUnit.Case
  doctest LibConfig

  test "greets the world" do
    assert LibConfig.hello() == :world
  end
end
