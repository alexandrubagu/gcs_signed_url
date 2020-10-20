defmodule GcsSignedUrl.Crypto do
  @moduledoc """
  Provides crypto functionality like signing and hashing strings.
  """

  alias GcsSignedUrl.{Client, SignBlob}

  @doc """
  If you pass a `%GcsSignedUrl.Client{}` as second argument, this function signs the given string with the given
  client's private key.

  If you pass a `%GcsSignedUrl.SignBlob.OAuthConfig{}` as second argument, this function signs the given string using
  the signBlob REST API.

  (see https://cloud.google.com/iam/docs/reference/rest/v1/projects.serviceAccounts/signBlob)

  ## Examples

      iex> GcsSignedUrl.Crypto.sign("foo", %GcsSignedUrl.Client{private_key: "-----BEGIN RSA PRIVATE KEY-----..."})
      "..."

      iex> GcsSignedUrl.Crypto.sign("foo", %GcsSignedUrl.SignBlob.OAuthConfig{access_token: "..."})
      {:ok, "1fad6186e41f577a37f56589..."}
  """
  @spec sign(String.t(), Client.t()) :: String.t()
  @spec sign(String.t(), SignBlob.OAuthConfig.t()) :: {:ok, String.t()} | {:error, String.t()}
  def sign(string_to_sign, %Client{} = client) do
    private_key = Client.get_decoded_private_key(client)
    :public_key.sign(string_to_sign, :sha256, private_key, rsa_padding: :rsa_pkcs1_padding)
  end

  def sign(string_to_sign, oauth_config) do
    with {:ok, %{body: raw_body}} <- do_post_request(string_to_sign, oauth_config),
         {:ok, body} <- Jason.decode(raw_body),
         %{"signedBlob" => signature} <- body do
      {:ok, signature}
    else
      error -> format_error(error)
    end
  end

  defp do_post_request(string_to_sign, oauth_config) do
    payload = Base.encode64(string_to_sign)

    sign_blob_http =
      Application.get_env(
        :gcs_signed_url,
        GcsSignedUrl.SignBlob.HTTP,
        GcsSignedUrl.SignBlob.HTTP
      )

    sign_blob_http.post(
      oauth_config.service_account,
      %{payload: payload},
      Authorization: "Bearer #{oauth_config.access_token}"
    )
  end

  # coveralls-ignore-start, reason: no logic worth testing.
  defp format_error(%{"error" => %{"code" => 401, "message" => message}}),
    do:
      {:error,
       "401 UNAUTHENTICATED: #{message} Make sure the access_token is valid and did not expire."}

  defp format_error(%{"error" => %{"code" => 403, "message" => message}}),
    do:
      {:error,
       "403 PERMISSION_DENIED: #{message} Make sure the authorized SA has role roles/iam.serviceAccountTokenCreator on the SA passed in the URL."}

  defp format_error(%{"error" => %{"code" => code, "message" => message, "status" => status}}),
    do: {:error, "#{code} #{status}: #{message}"}

  defp format_error(%{reason: reason}),
    do: {:error, "Error during HTTP request: #{reason}"}

  defp format_error(_error),
    do: {:error, "An unexpected error occurred during the API call to the signBlob API."}

  # coveralls-ignore-stop

  @doc """
  Hashed the given string using sha256 algorithm and encode it as lowercase hex string.

  ## Examples

      iex> GcsSignedUrl.Crypto.sha256("foo")
      "1fad6186e41f577a37f56589..."
  """
  @spec sha256(String.t()) :: String.t()
  def sha256(string) do
    :crypto.hash(:sha256, string)
    |> Base.encode16()
    |> String.downcase()
  end
end
