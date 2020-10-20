defmodule GcsSignedUrl.StringToSign do
  @moduledoc """
  Generates the string-to-sign and the URL the signature is being signed.
  """
  alias GcsSignedUrl.{CanonicalRequest, Crypto, Headers, ISODateTime, QueryString}

  @host "storage.googleapis.com"

  @type t :: %__MODULE__{
          string_to_sign: String.t(),
          url_template: String.t()
        }

  @fields [
    :string_to_sign,
    :url_template
  ]
  @enforce_keys @fields
  defstruct @fields

  @doc """
  Creates the string to sign according to https://cloud.google.com/storage/docs/authentication/signatures#string-to-sign
  and returns it together with a template of the URL that is being signed.

  The URL template contains a placeholder #SIGNATURE# for the actual signature.
  """
  @spec generate_v4(
          String.t(),
          String.t(),
          String.t(),
          GcsSignedUrl.sign_v4_opts()
        ) :: __MODULE__.t()
  def generate_v4(client_email, bucket, filename, opts \\ []) do
    expires = Keyword.get(opts, :expires, 15 * 60)
    verb = Keyword.get(opts, :verb, "GET")
    additional_headers = Keyword.get(opts, :headers, [])
    additional_query_params = Keyword.get(opts, :query_params, [])
    valid_from = Keyword.get(opts, :valid_from, DateTime.utc_now())

    resource = "/#{bucket}/#{filename}"
    iso_date_time = ISODateTime.generate(valid_from)
    credential_scope = "#{iso_date_time.date}/auto/storage/goog4_request"

    headers = Headers.create([host: @host] ++ additional_headers)

    query_string =
      QueryString.create(
        client_email,
        credential_scope,
        iso_date_time,
        headers,
        expires,
        additional_query_params
      )

    canonical_request = CanonicalRequest.create(verb, resource, query_string, headers)

    string_to_sign =
      "GOOG4-RSA-SHA256\n#{iso_date_time.datetime}\n#{credential_scope}\n#{
        Crypto.sha256(canonical_request)
      }"

    url_template = "https://#{@host}#{resource}?#{query_string}&X-Goog-Signature=#SIGNATURE#"

    %__MODULE__{
      string_to_sign: string_to_sign,
      url_template: url_template
    }
  end

  @doc """
  Creates the string to sign according to https://cloud.google.com/storage/docs/access-control/signed-urls-v2
  and returns it together with a template for the URL that is being signed.

  The URL template contains a placeholder #SIGNATURE# for the actual signature.
  """
  @spec generate_v2(
          String.t(),
          String.t(),
          String.t(),
          GcsSignedUrl.sign_v2_opts()
        ) :: __MODULE__.t()
  def generate_v2(client_email, bucket, filename, opts \\ []) do
    verb = Keyword.get(opts, :verb, "GET")
    md5_digest = Keyword.get(opts, :md5_digest, "")
    content_type = Keyword.get(opts, :content_type, "")
    expires = Keyword.get(opts, :expires, GcsSignedUrl.hours_after(1))
    resource = "/#{bucket}/#{filename}"

    query_string =
      %{
        "GoogleAccessId" => client_email,
        "Expires" => expires
      }
      |> URI.encode_query()

    string_to_sign = "#{verb}\n#{md5_digest}\n#{content_type}\n#{expires}\n#{resource}"
    url_template = "https://#{@host}#{resource}?#{query_string}&Signature=#SIGNATURE#"

    %__MODULE__{
      string_to_sign: string_to_sign,
      url_template: url_template
    }
  end
end
