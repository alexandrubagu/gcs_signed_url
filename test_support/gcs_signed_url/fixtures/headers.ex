defmodule GcsSignedUrl.Fixtures.Headers do
  @headers_kw_1 ["X-Foo": "foo", "X-Foo": "BA\r\nR", "Content-Type": "application/json"]
  @headers_signed_1 "content-type;x-foo"
  @headers_canonical_1 "content-type:application/json\nx-foo:foo,BA  R\n"

  @headers_kw_2 ["X-Foo": "foo", "X-Foo": "BA\r\nR", "Content-Type": "application/json", "x-zed": "zed", "x-Foo": "gamma"]
  @headers_signed_2 "content-type;x-foo;x-zed"
  @headers_canonical_2 "content-type:application/json\nx-foo:foo,BA  R,gamma\nx-zed:zed\n"

  def headers_kw_1, do: @headers_kw_1
  def headers_1, do: %GcsSignedUrl.Headers{signed: @headers_signed_1, canonical: @headers_canonical_1}

  def headers_kw_2, do: @headers_kw_2
  def headers_2, do: %GcsSignedUrl.Headers{signed: @headers_signed_2, canonical: @headers_canonical_2}
end
