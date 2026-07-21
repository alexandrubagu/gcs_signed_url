defmodule GcsSignedUrl.SignBlob.HTTP do
  @moduledoc """
  https://cloud.google.com/iam/docs/reference/credentials/rest/v1/projects.serviceAccounts/signBlob

  Options passed to `Req.new/1` can be extended via the `:req_options` application
  environment, e.g. `config :gcs_signed_url, :req_options, plug: {Req.Test, GcsSignedUrl.SignBlob.HTTP}`.
  """

  @endpoint "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/"

  @spec post(String.t(), map(), String.t()) :: {:ok, Req.Response.t()} | {:error, Exception.t()}
  def post(service_account, body, access_token) do
    [
      url: @endpoint <> service_account <> ":signBlob",
      json: body,
      auth: {:bearer, access_token}
    ]
    |> Keyword.merge(Application.get_env(:gcs_signed_url, :req_options, []))
    |> Req.new()
    |> Req.post()
  end
end
