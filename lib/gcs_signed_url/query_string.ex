defmodule GcsSignedUrl.QueryString do
  @moduledoc """
  Manages aggregation and formatting of query parameters.
  """

  @doc """
    Adds required query parameters for signed URL, sorts them and encodes them as proper query string.
  """
  @spec create(
          GcsSignedUrl.Client.t(),
          String.t(),
          GcsSignedUrl.ISODateTime.t(),
          GcsSignedUrl.Headers.t(),
          integer | String.t(),
          Keyword.t()
        ) :: String.t()
  def create(client, credential_scope, iso_date_time, headers, expires, additional_query_params) do
    ([
       "X-Goog-Algorithm": "GOOG4-RSA-SHA256",
       "X-Goog-Credential": "#{client.client_email}/#{credential_scope}",
       "X-Goog-Date": iso_date_time.datetime,
       "X-Goog-SignedHeaders": headers.signed,
       "X-Goog-Expires": expires
     ] ++ additional_query_params)
    |> Enum.sort()
    |> URI.encode_query()
  end
end
