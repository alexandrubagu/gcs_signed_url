# gcs_signed_url - Create Signed URLs for Google Cloud Storage
[![Travis](https://travis-ci.org/alexandrubagu/gcs_signed_url.svg)](https://travis-ci.org/alexandrubagu/gcs_signed_url) [![Hex.pm](https://img.shields.io/hexpm/v/gcs_signed_url.svg?maxAge=2592000)](https://hex.pm/packages/gcs_signed_url) [![Hex.pm](https://img.shields.io/hexpm/dt/gcs_signed_url.svg?maxAge=2592000)](https://hex.pm/packages/gcs_signed_url) [![Hex.pm](https://img.shields.io/hexpm/l/gcs_signed_url.svg?maxAge=2592000)](https://hex.pm/packages/gcs_signed_url) [![Coverage Status](https://coveralls.io/repos/github/alexandrubagu/gcs_signed_url/badge.svg?branch=master)](https://coveralls.io/github/alexandrubagu/gcs_signed_url?branch=master)

## Important
This package works with elixir >= 1.8 and otp >= 22.3

## Hex Installation 

Add `gcs_signed_url` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:gcs_signed_url, "~> 0.4"}]
end
```

## Usage

This library creates signed URLs for the Google Cloud Storage in three steps:

 1. Create a string to sign (V2 and V4 signatures are supported)
 2. Sign the string to sign with the private key of a Google service account (GSA)
 3. Form the URL including the signature

The actual signing can be done on-premise on the machine your application is executed or it can be delegated to the
Google IAM SignBlob API. The method of signing depends on your setup. Both methods work for creating V2 or V4 signatures.

### Google IAM SingBlob API - Preferred on the GKE

If your application runs on the Google Kubernetes Engine, the preferred way of accessing Google Cloud services is
through a [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity). In this
scenario, you run your application under a Kubernetes service account (KSA) which is related to a GSA. Using
[Goth](https://github.com/peburrows/goth), you would get an OAuth2 access token and use it to create a signed URL
through the SignBlob API.

In this scenario, the GSA you get the access token for (`GSA_AUTH`) acts as a Google Service Account `GSA_SIGNER` and
signs the URL on his behalf. This requires the `GSA_AUTH` go have the Google IAM permission
**iam.serviceAccounts.signBlob** on the `GSA_SIGNER`, e.g. by giving it the built in
role **roles/iam.serviceAccountTokenCreator** on `GSA_SIGNER`.

`GSA_AUTH` and `GSA_SIGNER` can also be the same service account in which case he needs to have the permission
**iam.serviceAccounts.signBlob** on itself.

#### Example

```elixir
    iex> access_token = Goth.Token.for_scope("https://www.googleapis.com")
    iex> oauth_config = %GcsSignedUrl.SignBlob.OAuthConfig{service_account: "project@gcs_signed_url.iam.gserviceaccount.com", access_token: access_token}
    iex> GcsSignedUrl.generate_v4(oauth_config, "my-bucket", "my-object.jpg", verb: "PUT", expires: 1800, headers: ["Content-Type": "application/jpeg"])
    {:ok, "https://storage.googleapis.com/my-bucket/my-object.jpg?X-Goog-Expires=1800..."}
```

### On-Premise Signing

In this scenario you have a service account key in form of a JSON file on your machine. The library will use the
private key to create the signature, no network calls are needed.

1. Load the client
```elixir
iex> GcsSignedUrl.Client.load_from_file("/home/alexandrubagu/config/google.json")
```
or 

```elixir
iex> service_account = service_account_json_string |> Jason.decode!
iex> GcsSignedUrl.Client.load(service_account)
```
 
 2. Generate signed url (V2)
 ```elixir
 GcsSignedUrl.generate(client, "my-bucket", "my-object.mp4")
 GcsSignedUrl.generate(client, "my-bucket", "my-object.mp4", expires: GcsSignedUrl.hours_after(3))
 ```
