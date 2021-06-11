defmodule GcsSignedUrl.QueryString do
  @moduledoc """
  Manages aggregation and formatting of query parameters.
  """

  @doc """
  Adds required query parameters for signed URL, sorts them and encodes them as proper query string.
  """
  @spec create(
          String.t(),
          String.t(),
          GcsSignedUrl.ISODateTime.t(),
          GcsSignedUrl.Headers.t(),
          integer | String.t(),
          Keyword.t()
        ) :: String.t()
  def create(
        client_email,
        credential_scope,
        iso_date_time,
        headers,
        expires,
        additional_query_params
      ) do
    ([
       "X-Goog-Algorithm": "GOOG4-RSA-SHA256",
       "X-Goog-Credential": "#{client_email}/#{credential_scope}",
       "X-Goog-Date": iso_date_time.datetime,
       "X-Goog-SignedHeaders": headers.signed,
       "X-Goog-Expires": expires
     ] ++ additional_query_params)
    |> Enum.sort()
    |> encode_query_rfc3986()
  end

  @spec encode_query_rfc3986(Enumerable.t()) :: String.t()
  def encode_query_rfc3986(pairs) do
    # We should encode a space as '%20'.
    # Elixir 1.12+ exposes this choice in URI.encode_query/2 as the second parameter, see the docs
    # at https://hexdocs.pm/elixir/1.12/URI.html#encode_query/2.
    # The code below replicates the implementation in Elixir 1.12.
    Enum.map_join(pairs, "&", &encode_kv_pair_rfc3986/1)
  end

  # taken from
  # https://github.com/elixir-lang/elixir/blob/03859fb92edc56a1cb5d7436b6bec282156198dc/lib/elixir/lib/uri.ex#L128-L131
  defp encode_kv_pair_rfc3986({key, value}) do
    URI.encode(Kernel.to_string(key), &URI.char_unreserved?/1) <>
      "=" <> URI.encode(Kernel.to_string(value), &URI.char_unreserved?/1)
  end
end
