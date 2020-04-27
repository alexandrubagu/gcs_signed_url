defmodule GcsSignedUrl.Crypto do
  @moduledoc """
  Provides crypto functionality like signing and hashing strings.
  """

  alias GcsSignedUrl.{Client, SignBlob}

  @sign_blob_http Application.get_env(:gcs_signed_url, GcsSignedUrl.SignBlob.HTTP)

  @doc """
  Signs the given string with the given client's private key

  ## Examples

      iex> GcsSignedUrl.Crypto.sign32("foo", %GcsSignedUrl.Client{private_key: "-----BEGIN RSA PRIVATE KEY-----..."})
      "1fad6186e41f577a37f56589..."
  """
  @spec sign(String.t(), Client.t()) :: String.t()
  def sign(string_to_sign, %Client{} = client) do
    private_key = Client.get_decoded_private_key(client)
    :public_key.sign(string_to_sign, :sha256, private_key, rsa_padding: :rsa_pkcs1_padding)
  end

  @doc """
  Signs the given string via the signBlob REST API
  (see https://cloud.google.com/iam/docs/reference/rest/v1/projects.serviceAccounts/signBlob)

  ## Examples

      iex> GcsSignedUrl.Crypto.sign_via_api("foo", %GcsSignedUrl.OAuthConfig{access_token: "..."})
      {:ok, "1fad6186e41f577a37f56589..."}
  """
  @spec sign(String.t(), SignBlob.OAuthConfig.t()) :: String.t()
  def sign(string_to_sign, %SignBlob.OAuthConfig{
        service_account: service_account,
        access_token: access_token
      }) do
    payload = Base.encode64(string_to_sign)

    with {:ok, %HTTPoison.Response{body: raw_body}} <-
           @sign_blob_http.post(
             service_account,
             %{payload: payload},
             Authorization: "Bearer #{access_token}"
           ),
         {:ok, body} <- Jason.decode(raw_body),
         %{"signedBlob" => signature} <- body do
      {:ok, signature}
    else
      %{"error" => %{"code" => 401, "message" => message}} ->
        {:error,
         "401 UNAUTHENTICATED: #{message} Make sure the access_token is valid and did not expire."}

      %{"error" => %{"code" => 403, "message" => message}} ->
        {:error,
         "403 PERMISSION_DENIED: #{message} Make sure the authorized SA has role roles/iam.serviceAccountTokenCreator on the SA passed in the URL."}

      %{"error" => %{"code" => code, "message" => message, "status" => status}} ->
        {:error, "#{code} #{status}: #{message}"}

      %HTTPoison.Error{reason: reason} ->
        {:error, "Error during HTTP request: #{reason}"}

      _error ->
        {:error, "An unexpected error occurred during the API call to the signBlob API."}
    end
  end

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
