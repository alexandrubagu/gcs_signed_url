defmodule GcsSignedUrl.SignBlob.OAuthConfig do
  @moduledoc """
  Defines Google Cloud OAuth2 Config. The service account should be an email or unique ID of an existing Google service
  account `GSA_SIGNER`. The access token should belong to a Google service account `GSA_AUTH`.

  In this scenario, the `GSA_AUTH` acts as `GSA_SIGNER` and signs the given string on his behalf. This requires the `GSA_AUTH`
  go have the Google IAM permission **iam.serviceAccounts.signBlob** on the `GSA_SIGNER`, e.g. by giving it the built in
  role **roles/iam.serviceAccountTokenCreator** on `GSA_SIGNER`.
  """

  @type t :: %__MODULE__{
          service_account: String.t(),
          access_token: String.t()
        }

  @fields [
    :service_account,
    :access_token
  ]
  @enforce_keys @fields
  defstruct @fields
end
