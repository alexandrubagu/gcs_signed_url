defmodule GcsSignedUrl do
  @moduledoc """
  Create Signed URLs for Google Cloud Storage in Elixir
  """
  @base_url "https://storage.googleapis.com"

  @type sign_opts :: [
          verb: String.t(),
          md5_digest: String.t(),
          content_type: String.t(),
          expires: integer()
        ]

  @doc """
  Generate signed url.

  ## Examples

      iex> client = GcsSignedUrl.Client.load(%{private_key: "...", client_email: "..."})
      iex> GcsSignedUrl.generate(client, "my-bucket", "my-object.mp4", expires: 1503599316)
      "https://storage.googleapis.com/my-bucket/my-object.mp4?Expires=15..."

  """
  @spec generate(
          GcsSignedUrl.Client.t(),
          String.t(),
          String.t(),
          sign_opts
        ) :: String.t()
  def generate(client, bucket, filename, opts \\ []) do
    verb = Keyword.get(opts, :verb, "GET")
    md5_digest = Keyword.get(opts, :md5_digest, "")
    content_type = Keyword.get(opts, :content_type, "")
    expires = Keyword.get(opts, :expires, hours_after(1))
    resource = "/#{bucket}/#{filename}"

    signature =
      [verb, md5_digest, content_type, expires, resource]
      |> Enum.join("\n")
      |> generate_signature(client)

    url = "#{@base_url}#{resource}"

    query_string =
      %{
        "GoogleAccessId" => client.client_email,
        "Expires" => expires,
        "Signature" => signature
      }
      |> URI.encode_query()

    Enum.join([url, "?", query_string])
  end

  @doc """
  Calculate future timestamp from given hour offset.

  ## Examples

      iex> 10 |> GcsUrlSigner.hours_after
      1503599316

  """
  def hours_after(hour) do
    DateTime.utc_now() |> DateTime.to_unix() |> Kernel.+(hour * 3600)
  end

  defp generate_signature(string, client) do
    private_key = get_private_key(client)

    string
    |> :public_key.sign(:sha256, private_key)
    |> Base.encode64()
  end

  defp get_private_key(client) do
    client.private_key
    |> :public_key.pem_decode()
    |> (fn [x] -> x end).()
    |> :public_key.pem_entry_decode()
  end
end
