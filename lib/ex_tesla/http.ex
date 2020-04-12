defmodule ExTesla.Http do
  @moduledoc false

  defp check_response(response) do
    case response.status_code do
      200 -> :ok
      status -> {:error, "Got HTTP status #{status}"}
    end
  end

  def get(url, opts \\ []) do
    {headers, opts} = Keyword.pop(opts, :headers, %{})
    headers = Enum.to_list(headers)

    with {:ok, response} <- Mojito.request(:get, url, headers, "", opts),
         :ok <- check_response(response),
         {:ok, out_data} <- Jason.decode(response.body) do
      {:ok, out_data}
    else
      {:error, error} -> {:error, "http get error #{inspect(error)}"}
    end
  end

  def post(url, in_data, opts \\ []) do
    default_headers = %{
      "Content-Type" => "application/json"
    }

    {headers, opts} = Keyword.pop(opts, :headers, %{})
    headers = Map.merge(default_headers, headers) |> Map.to_list()

    with {:ok, body} <- Jason.encode(in_data),
         {:ok, response} <- Mojito.request(:post, url, headers, body, opts),
         :ok <- check_response(response),
         {:ok, out_data} <- Jason.decode(response.body) do
      {:ok, out_data}
    else
      {:error, error} -> {:error, "http post error #{inspect(error)}"}
    end
  end
end
