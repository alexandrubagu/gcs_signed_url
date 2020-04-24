defmodule GcsSignedUrl.QueryStringTest do
  use ExUnit.Case
  alias GcsSignedUrl.{Client, Headers, ISODateTime}
  alias GcsSignedUrl.QueryString, as: MUT

  describe "create/6" do
    test "creates query string according to specs" do
      client = Client.load("test/gcs_config_sample.json")
      iso_date_time = %ISODateTime{datetime: "some-date-time", date: "some-date"}
      headers = %Headers{canonical: "some-canonical-headers", signed: "some-signed-headers"}

      query_string =
        MUT.create(client, "some-credential-scope", iso_date_time, headers, 500, foo: "bar")

      assert "X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=project%40gcs_signed_url.iam.gserviceaccount.com%2Fsome-credential-scope&X-Goog-Date=some-date-time&X-Goog-Expires=500&X-Goog-SignedHeaders=some-signed-headers&foo=bar" ==
               query_string
    end
  end
end
