defmodule GcsSignedUrl.ClientTest do
  use ExUnit.Case
  alias GcsSignedUrl.Client, as: MUT
  alias GcsSignedUrl.Fixtures.Client, as: Fixtures

  describe "load/1" do
    test "returns client struct for correct file" do
      client = MUT.load("test/gcs_config_sample.json")
      assert client.__struct__ == MUT
    end

    test "returns correct data" do
      client = MUT.load("test/gcs_config_sample.json")
      assert client == Fixtures.client_from_json()
    end

    test "returns error for inexisting file" do
      assert {:error, _} = MUT.load("some_path/data.txt")
    end
  end

  describe "get_decoded_private_key/1" do
    test "returns string" do
      client = MUT.load("test/gcs_config_sample.json")
      private_key = MUT.get_decoded_private_key(client)

      assert Fixtures.decoded_private_key_from_json() == private_key
    end
  end
end
