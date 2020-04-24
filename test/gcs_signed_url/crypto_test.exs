defmodule GcsSignedUrl.CryptoTest do
  use ExUnit.Case
  alias GcsSignedUrl.Crypto, as: MUT
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
end
