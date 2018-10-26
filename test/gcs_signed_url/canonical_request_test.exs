defmodule GcsSignedUrl.CanonicalRequestTest do
  use ExUnit.Case
  alias GcsSignedUrl.CanonicalRequest, as: MUT
  alias GcsSignedUrl.Fixtures.Headers, as: HeadersFixtures

  describe "create/4" do
    test "creates canonical request according to specs" do
      headers = HeadersFixtures.headers_2()

      canonical_request = MUT.create("GET", "bucket/object.jpg", "foo=bar&alpha=beta", headers)
      assert "GET\nbucket/object.jpg\nfoo=bar&alpha=beta\n#{headers.canonical}\n#{headers.signed}\nUNSIGNED-PAYLOAD" == canonical_request
    end
  end
end
