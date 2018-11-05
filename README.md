# ExTesla

Unofficial thin elixir wrapper for Tesla API. As per unofficial
[documentation](https://timdorr.docs.apiary.io/).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_tesla` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_tesla, "~> 0.0.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_tesla](https://hexdocs.pm/ex_tesla).

## Sample Usage

```elixir
{:ok, token} = ExTesla.get_token
client = ExTesla.client(token)
{:ok, result} = ExTesla.list_all_vehicles(client)
Enum.each(result, fn vehicle ->
    IO.puts(vehicle["display_name"])
    IO.inspect(vehicle)

    {:ok, vehicle_state} = ExTesla.get_vehicle_state(client, vehicle)
    IO.inspect(vehicle_state)

    {:ok, charge_state} = ExTesla.get_charge_state(client, vehicle)
    IO.inspect(charge_state)

    {:ok, climate_state} = ExTesla.get_climate_state(client, vehicle)
    IO.inspect(climate_state)

    {:ok, drive_state} = ExTesla.get_drive_state(client, vehicle)
    IO.inspect(drive_state)
end)

...

# Some time elapsed, need to check token hasn't expired.
{:ok, token} = ExTesla.check_token(token)
client = ExTesla.client(token)
{:ok, result} = ExTesla.list_all_vehicles(client)
```

## Disclaimers

This API should not be considered final and is subject to change.
