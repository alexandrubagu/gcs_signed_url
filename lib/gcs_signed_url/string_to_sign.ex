defmodule GcsSignedUrl.StringToSign do
  @moduledoc """
  Creates the string to sign according to https://cloud.google.com/storage/docs/authentication/signatures#string-to-sign
  """

  alias GcsSignedUrl.Crypto

  @spec create(GcsSignedUrl.ISODateTime.t(), String.t(), String.t()) :: String.t()
  def create(iso_date_time, credential_scope, canonical_request) do
    "GOOG4-RSA-SHA256\n#{iso_date_time.datetime}\n#{credential_scope}\n#{Crypto.sha256(canonical_request)}"
  end

end
