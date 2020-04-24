defmodule GcsSignedUrl.HeadersTest do
  use ExUnit.Case
  alias GcsSignedUrl.Fixtures.Headers, as: Fixtures
  alias GcsSignedUrl.Headers, as: MUT

  describe "create/1" do
    test "returns the headers object with signed and canonical representations of the headers set 1" do
      headers = MUT.create(Fixtures.headers_kw_1())

      assert Fixtures.headers_1() === headers
    end

    test "returns the headers object with signed and canonical representations of the headers set 2" do
      headers = MUT.create(Fixtures.headers_kw_2())

      assert Fixtures.headers_2() === headers
    end
  end
end
