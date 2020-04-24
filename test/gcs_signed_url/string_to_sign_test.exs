defmodule GcsSignedUrl.StringToSignTest do
  use ExUnit.Case

  alias GcsSignedUrl.ISODateTime
  alias GcsSignedUrl.StringToSign, as: MUT

  describe "create/3" do
    test "creates string to sign according to specs" do
      iso_date_time = %ISODateTime{datetime: "some-date-time", date: "some-date"}

      canonical_request =
        MUT.create(iso_date_time, "some-credential-scope", "some-canonical-request")

      assert "GOOG4-RSA-SHA256\nsome-date-time\nsome-credential-scope\n350d2fce071d410249ee691aae98e41231efb130d35fd4d6c6bda0cb18d9213b" ==
               canonical_request
    end
  end
end
