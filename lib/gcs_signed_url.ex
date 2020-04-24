defmodule GcsSignedUrl do
  @moduledoc """
  Create Signed URLs for Google Cloud Storage in Elixir
  """

  alias GcsSignedUrl.{CanonicalRequest, Crypto, Headers, ISODateTime, QueryString, StringToSign}

  @host "storage.googleapis.com"
  @base_url "https://#{@host}"

  @type sign_v2_opts :: [
                          verb: String.t(),
                          md5_digest: String.t(),
                          content_type: String.t(),
                          expires: integer()
                        ]

  @type sign_v4_opts :: [
                          verb: String.t(),
                          headers: Keyword.t(),
                          query_params: Keyword.t(),
                          valid_from: DateTime.t(),
                          expires: integer,
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
          sign_v2_opts
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
      |> Crypto.sign64(client)

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
  Generate signed url.

  ## Examples

      iex> client = GCSSignedURLV4.Client.load(%{private_key: "...", client_email: "..."})
      iex> GCSSignedURLV4.generate(client, "my-bucket", "my-object.mp4", verb: "PUT", expires: 1800, headers: [{:"Content-Type", "application/json"}])
      "https://storage.googleapis.com/my-bucket/my-object.mp4?X-Goog-Expires=1800..."

  """
  @spec generate_v4(
          GcsSignedUrl.Client.t(),
          String.t(),
          String.t(),
          sign_v4_opts
        ) :: String.t()
  def generate_v4(client, bucket, filename, opts \\ []) do
    expires = Keyword.get(opts, :expires, 15 * 60)
    verb = Keyword.get(opts, :verb, "GET")
    additional_headers = Keyword.get(opts, :headers, [])
    additional_query_params = Keyword.get(opts, :query_params, [])
    valid_from = Keyword.get(opts, :valid_from, DateTime.utc_now())

    resource = "/#{bucket}/#{filename}"
    iso_date_time = ISODateTime.generate(valid_from)
    credential_scope = "#{iso_date_time.date}/auto/storage/goog4_request"

    headers = Headers.create([host: @host] ++ additional_headers)
    query_string = QueryString.create(client, credential_scope, iso_date_time, headers, expires, additional_query_params)
    canonical_request = CanonicalRequest.create(verb, resource, query_string, headers)

    string_to_sign = StringToSign.create(iso_date_time, credential_scope, canonical_request)
    signature = Crypto.sign16(string_to_sign, client)

    "https://#{@host}#{resource}?#{query_string}&X-Goog-Signature=#{signature}"
  end

  @doc """
  Calculate future timestamp from given hour offset.

  ## Examples

      iex> 10 |> GcsUrlSigner.hours_after
      1503599316

  """
  def hours_after(hour) do
    DateTime.utc_now()
    |> DateTime.to_unix()
    |> Kernel.+(hour * 3600)
  end
end
