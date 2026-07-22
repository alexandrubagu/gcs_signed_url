defmodule GcsSignedUrl.MockSetup.Crypto do
  @type opts :: [
          error: atom
        ]

  @doc """
  Use this function to stub the HTTP requests in order to call sign/2.

  ## Options

  `:error` -   Pass the error option if you want to simulate the API call to return an error.

  * `:unauthenticated`
  * `:permission_denied`
  * `:other_api_error`
  * `:network`
  * `:unexpected`
  """
  @spec sign() :: :ok
  @spec sign(opts) :: :ok
  def sign(opts \\ []) do
    error = Keyword.get(opts, :error)

    Req.Test.stub(GcsSignedUrl.SignBlob.HTTP, fn conn ->
      case error do
        nil ->
          Req.Test.json(conn, %{"keyId" => "some_key", "signedBlob" => "c2lnbmF0dXJlCg=="})

        :unauthenticated ->
          error_response(conn, 401, "Some Message", "UNAUTHENTICATED")

        :permission_denied ->
          error_response(conn, 403, "Some Message", "PERMISSION_DENIED")

        :other_api_error ->
          error_response(conn, 404, "Some Message", "SOME_STATUS")

        :network ->
          Req.Test.transport_error(conn, :econnrefused)

        :unexpected ->
          Req.Test.json(conn, %{"something" => "unexpected"})

        :not_json ->
          conn
          |> Plug.Conn.put_status(301)
          |> Req.Test.text("Not JSON")
      end
    end)

    :ok
  end

  defp error_response(conn, code, message, status) do
    conn
    |> Plug.Conn.put_status(code)
    |> Req.Test.json(%{
      "error" => %{
        "code" => code,
        "message" => message,
        "status" => status
      }
    })
  end
end
