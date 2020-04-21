defmodule GcsSignedUrlV4Test do
  use ExUnit.Case

  alias GcsSignedUrlV4, as: MUT
  @host "storage.googleapis.com"

  describe "generate/4" do

    test "generates a signature" do
      client = GcsSignedUrl.Client.load_from_file("test/gcs_config_sample.json")
      bucket = "my-bucket"
      filename = "my-object.mp4"

      signed_url = MUT.generate(client, bucket, filename)
      signed_url_parts = URI.parse(signed_url)

      query_string =
        signed_url_parts
        |> Map.fetch!(:query)
        |> URI.decode_query()

      assert is_map(signed_url_parts)
      assert @host == Map.get(signed_url_parts, :host)
      assert "/#{bucket}/#{filename}" == Map.get(signed_url_parts, :path)
      assert is_map(query_string)
      assert Map.get(query_string, "X-Goog-Signature", false)
    end

    test "adds expires header" do
      client = GcsSignedUrl.Client.load_from_file("test/gcs_config_sample.json")

      signed_url = MUT.generate(client, "my-bucket", "my-object.mp4", expires: 1400)
      signed_url_parts = URI.parse(signed_url)

      query_string =
        signed_url_parts
        |> Map.fetch!(:query)
        |> URI.decode_query()

      assert is_map(query_string)
      assert "1400" == Map.get(query_string, "X-Goog-Expires")
    end
  end
end
