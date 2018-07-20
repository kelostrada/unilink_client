defmodule UnilinkClientTest do
  use ExUnit.Case
  doctest UnilinkClient

  test "greets the world" do
    assert UnilinkClient.hello() == :world
  end
end
