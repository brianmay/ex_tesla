# TeslaApi

Unofficial thin elixir wrapper for Tesla API. As per unofficial
[documentation](https://timdorr.docs.apiary.io/).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `tesla_api` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tesla_api, "~> 0.0.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/tesla_api](https://hexdocs.pm/tesla_api).

## Sample Usage

```elixir
{:ok, token} = TeslaApi.get_token
client = TeslaApi.client(token)
{:ok, result} = TeslaApi.list_all_vehicles(client)
Enum.each(result, fn vehicle ->
    IO.puts(vehicle["display_name"])
    IO.inspect(vehicle)

    {:ok, vehicle_state} = TeslaApi.get_vehicle_state(client, vehicle)
    IO.inspect(vehicle_state)

    {:ok, charge_state} = TeslaApi.get_charge_state(client, vehicle)
    IO.inspect(charge_state)

    {:ok, climate_state} = TeslaApi.get_climate_state(client, vehicle)
    IO.inspect(climate_state)

    {:ok, drive_state} = TeslaApi.get_drive_state(client, vehicle)
    IO.inspect(drive_state)
end)

...

# Some time elapsed, need to check token hasn't expired.
{:ok, token} = TeslaApi.check_token(token)
client = TeslaApi.client(token)
{:ok, result} = TeslaApi.list_all_vehicles(client)
```

## Disclaimers

This API is should not be considered final and is subject to change.
