defmodule ExTesla.Oauth do
  @moduledoc false

  alias ExTesla.Http

  @doc """
  Get the OAUTH parameters required for Tesla's API.
  """
  def get_oauth do
    url = "https://pastebin.com/raw/0a8e0xTJ"
    Http.get(url)
  end
end
