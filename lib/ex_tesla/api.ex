defmodule ExTesla.Api do
  @moduledoc """
  This is the HTTP API for Tesla API. It contains the low level HTTP functions.
  """
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://owner-api.teslamotors.com/")
  plug(Tesla.Middleware.JSON)

  defp login_with_oauth(oauth) do
    url = "/oauth/token"

    data = %{
      grant_type: "password",
      client_id: oauth["v1"]["id"],
      client_secret: oauth["v1"]["secret"],
      email: Application.get_env(:ex_tesla, :email),
      password: Application.get_env(:ex_tesla, :password)
    }

    result = post(url, data)

    case result do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, result} -> {:error, "Got status #{result.status}"}
      err -> err
    end
  end

  @doc """
  Get a token required for Tesla's API.
  """
  def get_token do
    with {:ok, oauth} <- ExTesla.Oauth.get_oauth(),
         {:ok, result} <- login_with_oauth(oauth) do
      {:ok, result}
    else
      err -> err
    end
  end

  @doc """
  Check token is still valid and renew if required.
  """
  def check_token(token) do
    now = :os.system_time(:seconds)
    expires = token["created_at"] + token["expires_in"] - 86400

    cond do
      now > expires ->
        get_token()

      true ->
        {:ok, token}
    end
  end

  @doc """
  Get a HTTP client for the token.
  """
  def client(token) do
    Tesla.build_client([
      {Tesla.Middleware.Headers, [{"authorization", "Bearer " <> token["access_token"]}]}
    ])
  end

  defp process_response(result) do
    case result do
      {:ok, %{status: 200, body: %{"response" => response}}} -> {:ok, response}
      {:ok, %{status: 200}} -> {:error, "Got no body in response"}
      {:ok, result} -> {:error, "Got error status #{result.status}"}
      err -> err
    end
  end

  @doc """
  Get a list of all vehicles belonging to this account.
  """
  def list_all_vehicles(%Tesla.Client{} = client) do
    url = "/api/1/vehicles"
    get(client, url) |> process_response
  end

  @doc """
  Get the vehicle state for a vehicle.
  """
  def get_vehicle_state(%Tesla.Client{} = client, vehicle) do
    vehicle_id = vehicle["id"]
    url = "/api/1/vehicles/#{vehicle_id}/data_request/vehicle_state"
    get(client, url) |> process_response
  end

  @doc """
  Get the charge state for a vehicle.
  """
  def get_charge_state(%Tesla.Client{} = client, vehicle) do
    vehicle_id = vehicle["id"]
    url = "/api/1/vehicles/#{vehicle_id}/data_request/charge_state"
    get(client, url) |> process_response
  end

  @doc """
  Get the climate state for a vehicle.
  """
  def get_climate_state(%Tesla.Client{} = client, vehicle) do
    vehicle_id = vehicle["id"]
    url = "/api/1/vehicles/#{vehicle_id}/data_request/climate_state"
    get(client, url) |> process_response
  end

  @doc """
  Get the drive state for a vehicle.
  """
  def get_drive_state(%Tesla.Client{} = client, vehicle) do
    vehicle_id = vehicle["id"]
    url = "/api/1/vehicles/#{vehicle_id}/data_request/drive_state"
    get(client, url) |> process_response
  end
end
