defmodule ExTesla do
  @moduledoc """
  Unofficial thin elixir wrapper for Tesla API. As per unofficial
  [documentation](https://timdorr.docs.apiary.io/).
  """
  alias ExTesla.Api


  @doc """
  Convert miles to km.
  """
  def convert_miles_to_km(nil), do: nil

  def convert_miles_to_km(km) do
    km * 1.60934
  end

  @doc """
  Get a token required for Tesla's API.
  """
  def get_token(), do: Api.get_token()

  @doc """
  Check token is still valid and renew if required.
  """
  def check_token(token), do: Api.check_token(token)

  @doc """
  Get a HTTP client for the token.
  """
  def client(token), do: Api.client(token)

  @doc """
  Get a list of all vehicles belonging to this account.
  """
  def list_all_vehicles(client), do: Api.list_all_vehicles(client)

  @doc """
  Get all data for a vehicle.
  """
  def get_vehicle_data(client, vehicle), do: Api.get_vehicle_data(client, vehicle)

  @doc """
  Get the vehicle state for a vehicle.
  """
  def get_vehicle_state(client, vehicle), do: Api.get_vehicle_state(client, vehicle)

  @doc """
  Get the charge state for a vehicle.
  """
  def get_charge_state(client, vehicle), do: Api.get_charge_state(client, vehicle)

  @doc """
  Get the climate state for a vehicle.
  """
  def get_climate_state(client, vehicle), do: Api.get_climate_state(client, vehicle)

  @doc """
  Get the drive state for a vehicle.
  """
  def get_drive_state(client, vehicle), do: Api.get_drive_state(client, vehicle)
end
