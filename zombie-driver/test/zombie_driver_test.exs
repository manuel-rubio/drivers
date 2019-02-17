defmodule ZombieDriverTest do
  use ExUnit.Case
  doctest ZombieDriver

  test "greets the world" do
    assert ZombieDriver.hello() == :world
  end
end
