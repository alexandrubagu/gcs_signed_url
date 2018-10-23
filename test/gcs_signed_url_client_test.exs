defmodule GcsSignedUrlClientTest do
  use ExUnit.Case
  alias GcsSignedUrl.Client

  test "raise on load" do
    assert_raise FunctionClauseError, fn ->
      Client.load(%{
        a: 1,
        b: 2
      })
    end

    assert_raise FunctionClauseError, fn ->
      Client.load(%{})
    end

    assert_raise FunctionClauseError, fn ->
      Client.load(%{
        "private_key" => "private_key"
      })
    end
  end

  test "load ok" do
    client =
      Client.load(%{
        "private_key" => "private_key",
        "client_email" => "contact@alexandrubagu.info"
      })

    assert client.__struct__ == Client
  end

  test "load_from_file with unexisting file" do
    assert {:error, _} = Client.load_from_file("some_path/data.txt")
  end

  test "load_from_file with existing file" do
    client = Client.load_from_file("test/gcs_config_sample.json")
    assert client.__struct__ == Client
  end
end
