defmodule GcsSignedUrl.Client do
  @moduledoc """
  Defines Google Cloud Storage Signed Url Client
  """

  @type t :: %__MODULE__{
          private_key: String.t(),
          client_email: String.t()
        }

  @fields [
    :private_key,
    :client_email
  ]
  @enforce_keys @fields
  defstruct @fields

  @doc """
  Initialize GcsSignedUrl.Client with given map.

  ## Examples

      iex> service_account = service_account_json_string |> Jason.decode!
      iex> GcsSignedUrl.Client.load(service_account)
      %GcsSignedUrl.Client{...}

  """
  @spec load(map()) :: __MODULE__.t()
  def load(%{
        "private_key" => private_key,
        "client_email" => client_email
      }) do
    %__MODULE__{
      private_key: private_key,
      client_email: client_email
    }
  end

  @doc """
  Initialize GcsSignedUrl.Client using a config file.

  ## Examples

      iex>
      iex> GcsSignedUrl.Client.load_from_file("/home/alexandrubagu/config/google.json")
      %GcsSignedUrl.Client{...}

  """
  @spec load(String.t()) :: __MODULE__.t()
  def load_from_file(path) when is_binary(path) do
    with {:ok, content} <- File.read(path),
         {:ok, config} <- Jason.decode(content) do
      load(config)
    end
  end

  def load_from_file(_), do: {:error, "Please provide a path for config"}
end
