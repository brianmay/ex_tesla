defmodule ExTeslaTest do
  use ExUnit.Case
  doctest ExTesla

  test "convert_miles_to_km" do
    assert ExTesla.convert_miles_to_km(1) == 1.60934
  end
end
