defmodule GcsSignedUrlTest do
  use ExUnit.Case

  @host "storage.googleapis.com"
  @google_access_id "project@gcs_signed_url.iam.gserviceaccount.com"

  test "generate" do
    client = GcsSignedUrl.Client.load_from_file("test/gcs_config_sample.json")

    bucket = "my-bucket"
    filename = "my-object.mp4"

    signed_url = GcsSignedUrl.generate(client, "my-bucket", "my-object.mp4")
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
