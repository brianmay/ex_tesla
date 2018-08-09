defmodule TeslaApiTest do
  use ExUnit.Case
  doctest TeslaApi

  test "greets the world" do
    assert TeslaApi.hello() == :world
  end
end
