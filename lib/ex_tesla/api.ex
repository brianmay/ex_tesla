defmodule ExTesla.Api do
  @moduledoc false
  use Tesla

  defmodule Token do
    @type t :: %__MODULE__{
            access_token: String.t(),
            token_type: String.t(),
            expires_in: integer,
            refresh_token: String.t(),
            created_at: integer
          }
    @enforce_keys [:access_token, :token_type, :expires_in, :refresh_token, :created_at]
    @derive Jason.Encoder
    defstruct [:access_token, :token_type, :expires_in, :refresh_token, :created_at]
  end

  plug(Tesla.Middleware.BaseUrl, "https://owner-api.teslamotors.com/")

  plug(Tesla.Middleware.Headers, [
    {"User-Agent",
     "Mozilla/5.0 (Linux; Android 9.0.0; VS985 4G Build/LRX21Y; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/58.0.3029.83 Mobile Safari/537.36"}
  ])

  plug(Tesla.Middleware.JSON)

  defp get_token_with_password(oauth, email, password) do
    url = "/oauth/token"

    data = %{
      grant_type: "password",
      client_id: oauth["v1"]["id"],
      client_secret: oauth["v1"]["secret"],
      email: email,
      password: password
    }

    result = post(url, data)

    case result do
      {:ok, %{status: 200, body: body}} ->
        token = %Token{
          access_token: body["access_token"],
          token_type: body["token_type"],
          expires_in: body["expires_in"],
          refresh_token: body["refresh_token"],
          created_at: body["created_at"]
        }

        {:ok, token}

      {:ok, result} ->
        {:error, "Got status #{result.status}"}

      {:error, msg} ->
        {:error, msg}
    end
  end

  defp get_token_with_token(oauth, token) do
    url = "/oauth/token"

    data = %{
      grant_type: "refresh_token",
      client_id: oauth["v1"]["id"],
      client_secret: oauth["v1"]["secret"],
      refresh_token: token.refresh_token
    }

    result = post(url, data)

    case result do
      {:ok, %{status: 200, body: body}} ->
        token = %Token{
          access_token: body["access_token"],
          token_type: body["token_type"],
          expires_in: body["expires_in"],
          refresh_token: body["refresh_token"],
          created_at: body["created_at"]
        }

        {:ok, token}

      {:ok, result} ->
        {:error, "Got status #{result.status}"}

      {:error, msg} ->
        {:error, msg}
    end
  end

  @doc """
  Get a token required for Tesla's API.
  """
  def get_token(email, password) do
    with {:ok, oauth} <- ExTesla.Oauth.get_oauth(),
         {:ok, result} <- get_token_with_password(oauth, email, password) do
      {:ok, result}
    else
      {:error, msg} -> {:error, msg}
    end
  end

  @doc """
  Renew a token required for Tesla's API.
  """
  def renew_token(%Token{} = token) do
    with {:ok, oauth} <- ExTesla.Oauth.get_oauth(),
         {:ok, result} <- get_token_with_token(oauth, token) do
      {:ok, result}
    else
      {:error, msg} -> {:error, msg}
    end
  end

  @doc """
  Check token is still valid and renew if required.
  """
  def check_token(%Token{} = token) do
    now = :os.system_time(:seconds)
    expires = token.created_at + token.expires_in - 86400

    cond do
      now > expires ->
        renew_token(token)

      true ->
        {:ok, token}
    end
  end

  @doc """
  Get a HTTP client for the token.
  """
  def client(%Token{} = token) do
    Tesla.client([
      {Tesla.Middleware.Headers, [{"authorization", "Bearer " <> token.access_token}]}
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
  Get all data for a vehicle.
  """
  def get_vehicle_data(%Tesla.Client{} = client, vehicle) do
    vehicle_id = vehicle["id"]
    url = "/api/1/vehicles/#{vehicle_id}/data"
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
