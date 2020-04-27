defmodule GcsSignedUrlTest do
  use ExUnit.Case

  alias GcsSignedUrl, as: MUT

  @host "storage.googleapis.com"
  @google_access_id "project@gcs_signed_url.iam.gserviceaccount.com"

  describe "generate/4" do
    test "works as expected" do
      client = GcsSignedUrl.Client.load("test/gcs_config_sample.json")

      bucket = "my-bucket"
      filename = "my-object.mp4"

      signed_url = MUT.generate(client, "my-bucket", "my-object.mp4")
      signed_url_parts = URI.parse(signed_url)

      query_string =
        signed_url_parts
        |> Map.fetch!(:query)
        |> URI.decode_query()

      assert is_map(signed_url_parts)
      assert @host == Map.get(signed_url_parts, :host)
      assert "/#{bucket}/#{filename}" == Map.get(signed_url_parts, :path)
      assert is_map(query_string)
      assert Map.get(query_string, "GoogleAccessId", false)
      assert @google_access_id == Map.get(query_string, "GoogleAccessId")
      assert Map.get(query_string, "Signature", false)
    end
  end

  describe "generate_v4/4" do
    test "Generates a URL with signature" do
      client = GcsSignedUrl.Client.load("test/gcs_config_sample.json")

      valid_from = %DateTime{
        year: 2000,
        month: 2,
        day: 29,
        zone_abbr: "AMT",
        hour: 23,
        minute: 0,
        second: 7,
        microsecond: {0, 0},
        utc_offset: 7200,
        std_offset: 0,
        time_zone: "Europe/Zurich"
      }

      signed_url =
        MUT.generate_v4(client, "bucket", "object.jpg", valid_from: valid_from, expires: 123)

      query_string =
        signed_url
        |> URI.parse()
        |> Map.fetch!(:query)
        |> URI.decode_query()

      assert Map.has_key?(query_string, "X-Goog-Signature")
    end
  end
end
