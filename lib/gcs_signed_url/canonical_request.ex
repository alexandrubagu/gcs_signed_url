defmodule GcsSignedUrl.CanonicalRequest do
  @moduledoc """
  Creates the canonical request accoring to https://cloud.google.com/storage/docs/authentication/canonical-requests
  """

  @spec create(GcsSignedUrl.ISODateTime.t(), String.t(), String.t(), GcsSignedUrl.Headers.t()) :: String.t()
  def create(verb, resource, query_string, headers) do
      "#{verb}\n#{resource}\n#{query_string}\n#{headers.canonical}\n#{headers.signed}\nUNSIGNED-PAYLOAD"
  end
end
