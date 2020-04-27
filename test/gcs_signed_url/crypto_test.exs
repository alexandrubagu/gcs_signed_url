defmodule GcsSignedUrl.CryptoTest do
  use ExUnit.Case
  alias GcsSignedUrl.SignBlob
  alias GcsSignedUrl.Crypto, as: MUT
  alias GcsSignedUrl.MockSetup.Crypto, as: MockSetup
  alias GcsSignedUrl.Fixtures.Crypto, as: Fixtures

  describe "sign16/1" do
    test "returns the signed hex string correctly" do
      client = GcsSignedUrl.Client.load("test/gcs_config_sample.json")
      assert Fixtures.foo_signed_16() == MUT.sign16("foo", client)
    end
  end

  describe "sign64/1" do
    test "returns the signed base64 string correctly" do
      client = GcsSignedUrl.Client.load("test/gcs_config_sample.json")
      assert Fixtures.foo_signed_64() == MUT.sign64("foo", client)
    end
  end

  describe "sign_via_api/2" do
    setup do
      [
        oauth_config: %SignBlob.OAuthConfig{
          access_token: "Some access token",
          service_account: "Some service account"
        },
        string_to_sign: "string-to-sign"
      ]
    end

    test "returns signature upon successful response from the HTTP client", %{
      oauth_config: oauth_config,
      string_to_sign: string_to_sign
    } do
      MockSetup.sign_via_api()
      assert {:ok, "signature"} == MUT.sign_via_api(string_to_sign, oauth_config)
    end

    test "returns error with details upon 401 response from API", %{
      oauth_config: oauth_config,
      string_to_sign: string_to_sign
    } do
      MockSetup.sign_via_api(error: :unauthenticated)
      assert {:error, message} = MUT.sign_via_api(string_to_sign, oauth_config)
      assert message =~ ~r/Make sure the access_token/
    end

    test "returns error with details upon 403 response from API", %{
      oauth_config: oauth_config,
      string_to_sign: string_to_sign
    } do
      MockSetup.sign_via_api(error: :permission_denied)
      assert {:error, message} = MUT.sign_via_api(string_to_sign, oauth_config)
      assert message =~ ~r/Make sure the authorized SA/
    end

    test "returns error with details upon response from API other than the above", %{
      oauth_config: oauth_config,
      string_to_sign: string_to_sign
    } do
      MockSetup.sign_via_api(error: :other_api_error)
      assert {:error, _message} = MUT.sign_via_api(string_to_sign, oauth_config)
    end

    test "returns error with details if there's network problems", %{
      oauth_config: oauth_config,
      string_to_sign: string_to_sign
    } do
      MockSetup.sign_via_api(error: :network)
      assert {:error, message} = MUT.sign_via_api(string_to_sign, oauth_config)
      assert message =~ ~r/Error during HTTP request:/
    end

    test "returns error with details if there's some other type of error", %{
      oauth_config: oauth_config,
      string_to_sign: string_to_sign
    } do
      MockSetup.sign_via_api(error: :unexpected)
      assert {:error, message} = MUT.sign_via_api(string_to_sign, oauth_config)
      assert message =~ ~r/unexpected error/
    end
  end
end
