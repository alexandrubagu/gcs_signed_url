defmodule GcsSignedUrl.Crypto do
  @moduledoc """
  Provides crypto functionality like signing and hashing strings.
  """

  alias GcsSignedUrl.Client

  @doc """
  Signs the given string with the given client's private key and encodes the resulting signature as lowercase hex
  string.

  ## Examples

      iex> GcsSignedUrl.Crypto.sign("foo", %GcsSignedUrl.Client{private_key: "-----BEGIN RSA PRIVATE KEY-----..."})
      "1fad6186e41f577a37f56589..."
  """
  @spec sign16(String.t(), Client.t()) :: String.t()
  def sign16(string, client) do
    private_key = Client.get_decoded_private_key(client)

    string
    |> :public_key.sign(:sha256, private_key, rsa_padding: :rsa_pkcs1_padding)
    |> Base.encode16()
    |> String.downcase()
  end

  @doc """
  Signs the given string with the given client's private key and encodes the resulting signature as lowercase base64
  string.

  ## Examples

      iex> GcsSignedUrl.Crypto.sign("foo", %GcsSignedUrl.Client{private_key: "-----BEGIN RSA PRIVATE KEY-----..."})
      "1fad6186e41f577a37f56589..."
  """
  @spec sign64(String.t(), Client.t()) :: String.t()
  def sign64(string, client) do
    private_key = Client.get_decoded_private_key(client)

    string
    |> :public_key.sign(:sha256, private_key, rsa_padding: :rsa_pkcs1_padding)
    |> Base.encode64()
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
