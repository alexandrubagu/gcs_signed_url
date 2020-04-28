defmodule GcsSignedUrlTest do
  use ExUnit.Case

  alias GcsSignedUrl, as: MUT
  alias GcsSignedUrl.SignBlob
  alias GcsSignedUrl.MockSetup.Crypto, as: CryptoMockSetup

  setup do
    [
      oauth_config: %SignBlob.OAuthConfig{
        access_token: "Some access token",
        service_account: "Some service account"
      },
      client: GcsSignedUrl.Client.load("test/gcs_config_sample.json")
    ]
  end

  describe "generate/4" do
    test "Generates a URL with a Signature query parameter for a given Client", %{client: client} do
      signed_url = MUT.generate(client, "my-bucket", "my-object.mp4")

      query_string =
        signed_url
        |> URI.parse()
        |> Map.fetch!(:query)
        |> URI.decode_query()

      assert Map.has_key?(query_string, "Signature")
    end

    test "Generates a URL with a Signature query parameter for a given OAuthConfig", %{
      oauth_config: oauth_config
    } do
      CryptoMockSetup.sign()
      {:ok, signed_url} = MUT.generate(oauth_config, "my-bucket", "my-object.mp4")

      query_string =
        signed_url
        |> URI.parse()
        |> Map.fetch!(:query)
        |> URI.decode_query()

      assert Map.has_key?(query_string, "Signature")
    end

    test "Return an error if API call fails", %{oauth_config: oauth_config} do
      CryptoMockSetup.sign(error: :permission_denied)
      assert {:error, _} = MUT.generate(oauth_config, "my-bucket", "my-object.mp4")
    end
  end

  describe "generate_v4/4" do
    test "Generates a URL with an X-Goog-Signature query parameter for a given Client", %{
      client: client
    } do
      signed_url = MUT.generate_v4(client, "bucket", "object.jpg")

      query_string =
        signed_url
        |> URI.parse()
        |> Map.fetch!(:query)
        |> URI.decode_query()

      assert Map.has_key?(query_string, "X-Goog-Signature")
    end

    test "Generates a URL with an X-Goog-Signature query parameter for a given OAuthConfig", %{
      oauth_config: oauth_config
    } do
      CryptoMockSetup.sign()
      {:ok, signed_url} = MUT.generate_v4(oauth_config, "bucket", "object.jpg")

      query_string =
        signed_url
        |> URI.parse()
        |> Map.fetch!(:query)
        |> URI.decode_query()

      assert Map.has_key?(query_string, "X-Goog-Signature")
    end

    test "Return an error if API call fails", %{oauth_config: oauth_config} do
      CryptoMockSetup.sign(error: :permission_denied)
      assert {:error, _} = MUT.generate_v4(oauth_config, "bucket", "object.jpg")
    end
  end
end
