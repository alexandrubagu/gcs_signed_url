defmodule GcsSignedUrl.SignBlob.HTTP do
  @moduledoc """


  https://cloud.google.com/iam/docs/reference/credentials/rest/v1/projects.serviceAccounts/signBlob
  """

  use HTTPoison.Base

  @endpoint "https://content-iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/"

  # coveralls-ignore-start, reason: no logic worth testing

  @spec process_url(binary) :: binary
  def process_url(service_account) do
    @endpoint <> service_account <> ":signBlob"
  end

  @spec process_request_body(term) :: binary
  def process_request_body(body) do
    Jason.encode!(body)
  end

  # coveralls-ignore-stop
end
