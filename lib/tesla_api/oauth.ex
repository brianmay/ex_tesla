defmodule TeslaApi.Oauth do
  @moduledoc """
  This contains functionality to retrieve parameters required for Tesla's API.
  """
  use Tesla

  @doc """
  Get the OAUTH parameters required for Tesla's API.
  """
  def get_oauth do
    url = "https://pastebin.com/raw/0a8e0xTJ"
    result = get(url)

    case result do
      {:ok, %{status: 200, body: body}} -> {:ok, Jason.decode!(body)}
      {:ok, result} -> {:error, "Got status #{result.status}"}
      err -> err
    end
  end
end
