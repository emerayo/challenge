defmodule ChallengeTest do
  use ExUnit.Case
  doctest Challenge

  test "greets the world" do
    assert Challenge.hello() == :world
  end
end
