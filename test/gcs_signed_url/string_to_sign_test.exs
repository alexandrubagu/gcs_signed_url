defmodule GcsSignedUrl.StringToSignTest do
  use ExUnit.Case

  alias GcsSignedUrl.StringToSign, as: MUT

  describe "generate_v4/4" do
    test "Generates string to sign and URL" do
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

      %MUT{string_to_sign: string_to_sign, url_template: url_template} =
        MUT.generate_v4("project@gcs_signed_url.iam.gserviceaccount.com", "bucket", "object.jpg",
          valid_from: valid_from,
          expires: 123
        )

      string_to_sign_parts = String.split(string_to_sign, "\n")

      assert url_template =~ ~r/#SIGNATURE#/
      assert 4 == Enum.count(string_to_sign_parts)
      assert "GOOG4-RSA-SHA256" == Enum.at(string_to_sign_parts, 0)
    end

    test "Generates string to sign and URL with custom domain" do
      %MUT{string_to_sign: string_to_sign, url_template: url_template} =
        MUT.generate_v4("project@gcs_signed_url.iam.gserviceaccount.com", "bucket", "object.jpg",
          host: "bucket.example.com"
        )

      string_to_sign_parts = String.split(string_to_sign, "\n")

      assert url_template =~ ~r/#SIGNATURE#/
      assert url_template =~ "https://bucket.example.com"

      assert 4 == Enum.count(string_to_sign_parts)
      assert "GOOG4-RSA-SHA256" == Enum.at(string_to_sign_parts, 0)
    end
  end

  describe "generate_v2/4" do
    test "Generates string to sign and URL" do
      %MUT{string_to_sign: string_to_sign, url_template: url_template} =
        MUT.generate_v2("project@gcs_signed_url.iam.gserviceaccount.com", "bucket", "object.jpg",
          expires: 123,
          verb: "POST",
          md5_digest: "some digest",
          content_type: "image/jpeg"
        )

      string_to_sign_parts = String.split(string_to_sign, "\n")

      assert url_template =~ ~r/#SIGNATURE#/
      assert 5 == Enum.count(string_to_sign_parts)
      assert "POST" == Enum.at(string_to_sign_parts, 0)
      assert "some digest" == Enum.at(string_to_sign_parts, 1)
      assert "image/jpeg" == Enum.at(string_to_sign_parts, 2)
      assert "123" == Enum.at(string_to_sign_parts, 3)
      assert "/bucket/object.jpg" == Enum.at(string_to_sign_parts, 4)
    end
  end
end
