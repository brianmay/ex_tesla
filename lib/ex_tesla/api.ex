defmodule ExTesla.Api do
  @moduledoc """
  API for Tesla
  """
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

  @spec make_url(String.t()) :: String.t()
  defp make_url(url) do
    "https://owner-api.teslamotors.com" <> url
  end

  @spec post(String.t(), map()) :: {:ok, map()} | {:error, String.t()}
  defp post(url, data) do
    headers = %{
      "User-Agent" =>
        "Mozilla/5.0 (Linux; Android 9.0.0; VS985 4G Build/LRX21Y; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/58.0.3029.83 Mobile Safari/537.36"
    }

    url = make_url(url)
    ExTesla.Http.post(url, data, headers: headers)
  end

  @spec post(Token.t(), String.t(), map()) :: {:ok, map()} | {:error, String.t()}
  defp post(%Token{} = token, url, data) do
    headers = %{
      "User-Agent" =>
        "Mozilla/5.0 (Linux; Android 9.0.0; VS985 4G Build/LRX21Y; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/58.0.3029.83 Mobile Safari/537.36",
      "authorization" => "Bearer " <> token.access_token
    }

    url = make_url(url)
    ExTesla.Http.post(url, data, headers: headers)
  end

  @spec get(Token.t(), String.t()) :: {:ok, map()} | {:error, String.t()}
  defp get(%Token{} = token, url) do
    headers = %{
      "User-Agent" =>
        "Mozilla/5.0 (Linux; Android 9.0.0; VS985 4G Build/LRX21Y; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/58.0.3029.83 Mobile Safari/537.36",
      "authorization" => "Bearer " <> token.access_token
    }

    url = make_url(url)
    ExTesla.Http.get(url, headers: headers)
  end

  @spec get_token_with_password(map(), String.t(), String.t()) ::
          {:ok, Token.t()} | {:error, String.t()}
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
      {:ok, body} ->
        token = %Token{
          access_token: body["access_token"],
          token_type: body["token_type"],
          expires_in: body["expires_in"],
          refresh_token: body["refresh_token"],
          created_at: body["created_at"]
        }

        {:ok, token}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec get_token_with_token(map(), Token.t()) :: {:ok, Token.t()} | {:error, String.t()}
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
      {:ok, body} ->
        token = %Token{
          access_token: body["access_token"],
          token_type: body["token_type"],
          expires_in: body["expires_in"],
          refresh_token: body["refresh_token"],
          created_at: body["created_at"]
        }

        {:ok, token}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get a token required for Tesla's API.
  """
  @spec get_token(String.t(), String.t()) :: {:ok, Token.t()} | {:error, String.t()}
  def get_token(email, password) do
    with {:ok, oauth} <- ExTesla.Oauth.get_oauth(),
         {:ok, result} <- get_token_with_password(oauth, email, password) do
      {:ok, result}
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Renew a token required for Tesla's API.
  """
  @spec renew_token(Token.t()) :: {:ok, Token.t()} | {:error, String.t()}
  def renew_token(%Token{} = token) do
    with {:ok, oauth} <- ExTesla.Oauth.get_oauth(),
         {:ok, result} <- get_token_with_token(oauth, token) do
      {:ok, result}
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Check token is still valid and renew if required.
  """
  @spec check_token(Token.t()) :: {:ok, Token.t()} | {:error, String.t()}
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

  @spec parse_response({:ok, map()} | {:error, String.t()}) :: {:ok, map()} | {:error, String.t()}
  def parse_response(response) do
    case response do
      {:ok, %{"response" => response}} -> {:ok, response}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Get a list of all vehicles belonging to this account.
  """
  @spec list_all_vehicles(Token.t()) :: {:ok, map()} | {:error, String.t()}
  def list_all_vehicles(%Token{} = token) do
    url = "/api/1/vehicles"
    get(token, url) |> parse_response()
  end

  @doc """
  Get all data for a vehicle.
  """
  @spec get_vehicle_data(Token.t(), map()) :: {:ok, map()} | {:error, String.t()}
  def get_vehicle_data(%Token{} = token, vehicle) do
    vehicle_id = vehicle["id"]
    url = "/api/1/vehicles/#{vehicle_id}/data"
    get(token, url) |> parse_response()
  end

  @doc """
  Get the vehicle state for a vehicle.
  """
  @spec get_vehicle_state(Token.t(), map()) :: {:ok, map()} | {:error, String.t()}
  def get_vehicle_state(%Token{} = token, vehicle) do
    vehicle_id = vehicle["id"]
    url = "/api/1/vehicles/#{vehicle_id}/data_request/vehicle_state"
    get(token, url) |> parse_response()
  end

  @doc """
  Get the charge state for a vehicle.
  """
  @spec get_charge_state(Token.t(), map()) :: {:ok, map()} | {:error, String.t()}
  def get_charge_state(%Token{} = token, vehicle) do
    vehicle_id = vehicle["id"]
    url = "/api/1/vehicles/#{vehicle_id}/data_request/charge_state"
    get(token, url) |> parse_response()
  end

  @doc """
  Get the climate state for a vehicle.
  """
  @spec get_climate_state(Token.t(), map()) :: {:ok, map()} | {:error, String.t()}
  def get_climate_state(%Token{} = token, vehicle) do
    vehicle_id = vehicle["id"]
    url = "/api/1/vehicles/#{vehicle_id}/data_request/climate_state"
    get(token, url) |> parse_response()
  end

  @doc """
  Get the drive state for a vehicle.
  """
  @spec get_drive_state(Token.t(), map()) :: {:ok, map()} | {:error, String.t()}
  def get_drive_state(%Token{} = token, vehicle) do
    vehicle_id = vehicle["id"]
    url = "/api/1/vehicles/#{vehicle_id}/data_request/drive_state"
    get(token, url) |> parse_response()
  end

  @spec parse_command_response({:ok, map()} | {:error, String.t()}) :: :ok | {:error, String.t()}
  def parse_command_response(response) do
    case response do
      {:ok, %{"response" => %{"result" => true}}} -> :ok
      {:ok, %{"response" => %{"reason" => reason}}} -> {:error, reason}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Wake up
  """
  @spec wake_up(Token.t(), map()) :: :ok | {:error, String.t()}
  def wake_up(%Token{} = token, vehicle) do
    vehicle_id = vehicle["id"]
    url = "/api/1/vehicles/#{vehicle_id}/command/wake_up"
    post(token, url, %{}) |> parse_command_response()
  end

  @doc """
  Start charging
  """
  @spec charge_start(Token.t(), map()) :: :ok | {:error, String.t()}
  def charge_start(%Token{} = token, vehicle) do
    vehicle_id = vehicle["id"]
    url = "/api/1/vehicles/#{vehicle_id}/command/charge_start"
    post(token, url, %{}) |> parse_command_response()
  end

  @doc """
  Start charging
  """
  @spec charge_stop(Token.t(), map()) :: :ok | {:error, String.t()}
  def charge_stop(%Token{} = token, vehicle) do
    vehicle_id = vehicle["id"]
    url = "/api/1/vehicles/#{vehicle_id}/command/charge_stop"
    post(token, url, %{}) |> parse_command_response()
  end

  @doc """
  Set charge limit
  """
  @spec set_charge_limit(Token.t(), map(), integer()) :: :ok | {:error, String.t()}
  def set_charge_limit(%Token{} = token, vehicle, percent) do
    vehicle_id = vehicle["id"]
    url = "/api/1/vehicles/#{vehicle_id}/command/set_charge_limit"
    data = %{"percent" => percent}
    post(token, url, data) |> parse_command_response()
  end
end
