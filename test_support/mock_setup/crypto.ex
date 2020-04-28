defmodule GcsSignedUrl.MockSetup.Crypto do

  import Mox

  @type opts :: [
                  error: atom,
                ]

  @doc """
  Use this function to setup the HTTP Mock in order to call sign/2.

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
  def sign(
        opts \\ []
      ) do
    error = Keyword.get(opts, :error)

    expect(
      GcsSignedUrl.SignBlob.HTTPMock,
      :post,
      fn (_service_account, _body, _headers) ->
        case error do
          nil -> {:ok, %HTTPoison.Response{status_code: 200, body: "{\"keyId\": \"some_key\", \"signedBlob\": \"c2lnbmF0dXJlCg==\"}"}}
          :unauthenticated -> create_fake_error_response(401, "Some Message", "UNAUTHENTICATED")
          :permission_denied -> create_fake_error_response(403, "Some Message", "PERMISSION_DEINED")
          :other_api_error -> create_fake_error_response(404, "Some Message", "SOME_STATUS")
          :network -> %HTTPoison.Error{reason: "Some Reason"}
          :unexpected -> "Some unexpected error"
        end
      end
    )

    :ok
  end

  defp create_fake_error_response(code, message, status) do
    {
      :ok,
      %HTTPoison.Response{
        body: Jason.encode!(
          %{
            "error" => %{
              "code" => code,
              "message" => message,
              "status" => status
            }
          }
        ),
        status_code: code
      }
    }
  end
end
