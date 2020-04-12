defmodule ExTesla do
  @moduledoc """
  Unofficial thin elixir wrapper for Tesla API. As per unofficial
  [documentation](https://timdorr.docs.apiary.io/).
  """
  alias ExTesla.Api

  @type token() :: map()
  @type error() :: {:error, String.t()}

  @doc """
  Convert miles to km.
  """
  @spec convert_miles_to_km(float | nil) :: float | nil
  def convert_miles_to_km(nil), do: nil

  def convert_miles_to_km(km) do
    km * 1.60934
  end

  defdelegate get_token(email, password), to: Api
  defdelegate check_token(token), to: Api
  defdelegate list_all_vehicles(token), to: Api
  defdelegate get_vehicle_data(token, vehicle), to: Api
  defdelegate get_vehicle_state(token, vehicle), to: Api
  defdelegate get_charge_state(token, vehicle), to: Api
  defdelegate get_climate_state(token, vehicle), to: Api
  defdelegate get_drive_state(token, vehicle), to: Api
  defdelegate wake_up(token, vehicle), to: Api
  defdelegate charge_start(token, vehicle), to: Api
  defdelegate charge_stop(token, vehicle), to: Api
  defdelegate set_charge_limit(token, vehicle, percent), to: Api
end
