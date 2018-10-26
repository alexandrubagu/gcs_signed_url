# gcs_signed_url - Create Signed URLs for Google Cloud Storage
[![Travis](https://travis-ci.org/alexandrubagu/gcs_signed_url.svg)](https://travis-ci.org/alexandrubagu/gcs_signed_url) [![Hex.pm](https://img.shields.io/hexpm/v/gcs_signed_url.svg?maxAge=2592000)](https://hex.pm/packages/gcs_signed_url) [![Hex.pm](https://img.shields.io/hexpm/dt/gcs_signed_url.svg?maxAge=2592000)](https://hex.pm/packages/gcs_signed_url) [![Hex.pm](https://img.shields.io/hexpm/l/gcs_signed_url.svg?maxAge=2592000)](https://hex.pm/packages/gcs_signed_url) [![Coverage Status](https://coveralls.io/repos/github/alexandrubagu/gcs_signed_url/badge.svg?branch=master)](https://coveralls.io/github/alexandrubagu/gcs_signed_url?branch=master)

## Important
This package works with elixir >= 1.8 and otp >= 22.3

## Hex Installation 

Add `gcs_signed_url` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:gcs_signed_url, "~> 1.0"}]
end
```

## Usage V4 Signatures

We advise to use [Goth](https://github.com/peburrows/goth) to authenticate against your Google Storage API:

```elixir
    iex> {:ok, private_key} = Goth.Config.get(:private_key)
    iex> {:ok, client_email} = Goth.Config.get(:client_email)

    %GcsSignedUrl.Client{private_key: private_key, client_email: client_email}
    |> GcsSignedUrl.generate_v4("my-bucket", "my-object.mp4", expires: 60*20, headers: ["Content-Type": "image/jpeg"])
```

## Usage Old V2 signatures

1. Load the client
```elixir
iex> GcsSignedUrl.Client.load_from_file("/home/alexandrubagu/config/google.json")
```
or 

```elixir
iex> service_account = service_account_json_string |> Jason.decode!
iex> GcsSignedUrl.Client.load(service_account)
```
 
 2. Generate signed url 
 ```elixir
 GcsSignedUrl.generate(client, "my-bucket", "my-object.mp4")
 GcsSignedUrl.generate(client, "my-bucket", "my-object.mp4", expires: GcsSignedUrl.hours_after(3))
 ```
