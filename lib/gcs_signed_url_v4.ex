defmodule GcsSignedUrlV4 do
  @moduledoc """
  Create V4 Signed URLs for Google Cloud Storage in Elixir
  https://cloud.google.com/storage/docs/access-control/signed-urls
  """
  @host "storage.googleapis.com"
  @goog_sign_algorithm "GOOG4-RSA-SHA256"
  @default_expires 900 # 15 minutes

  @type sign_opts :: [
                       verb: String.t(),
                       headers: Keyword.t(),
                       query_params: Keyword.t(),
                       expires: integer,
                     ]

  @doc """
  Generate signed url.

  ## Examples

      iex> client = GcsSignedUrlV4.Client.load(%{private_key: "...", client_email: "..."})
      iex> GcsSignedUrlV4.generate(client, "my-bucket", "my-object.mp4", verb: "PUT", expires: 1800, headers: [{:"Content-Type", "application/json"}])
      "https://storage.googleapis.com/my-bucket/my-object.mp4?X-Goog-Expires=1800..."

  """
  @spec generate(
          GcsSignedUrl.Client.t(),
          String.t(),
          String.t(),
          sign_opts
        ) :: String.t()
  def generate(client, bucket, filename, opts \\ []) do
    expires = Keyword.get(opts, :expires, @default_expires)
    verb = Keyword.get(opts, :verb, "GET")
    opt_headers = Keyword.get(opts, :headers, [])
    opt_query_params = Keyword.get(opts, :query_params, [])

    now = DateTime.utc_now()
          |> DateTime.truncate(:second)
    now_iso = now
              |> DateTime.to_iso8601(:basic)
    now_date = now
               |> DateTime.to_date()
               |> Date.to_iso8601(:basic)

    resource = "/#{bucket}/#{filename}"
    credential_scope = "#{now_date}/auto/storage/goog4_request"

    headers = [host: @host] ++ opt_headers
    signed_headers = create_signed_headers(headers)

    query_string =
      [
        {:"X-Goog-Algorithm", @goog_sign_algorithm},
        {:"X-Goog-Credential", "#{client.client_email}/#{credential_scope}"},
        {:"X-Goog-Date", now_iso},
        {:"X-Goog-SignedHeaders", signed_headers},
        {:"X-Goog-Expires", expires},
      ] ++ opt_query_params
      |> URI.encode_query()

    canonical_request = create_canonical_request(verb, resource, query_string, headers, signed_headers)

    string_to_sign =
      [
        @goog_sign_algorithm,
        now_iso,
        credential_scope,
        canonical_request,
      ]
      |> Enum.join("\n")

    signature = generate_signature(string_to_sign, client)

    Enum.join(["https://", @host, resource, "?", query_string, "&", "X-Goog-Signature=#{signature}"])
  end

  defp create_canonical_request(verb, resource, query_string, headers, signed_headers) do
    canonical_headers = headers
                        |> Enum.sort()
                        |> Enum.flat_map_reduce({nil,nil}, &group_concat/2)
                        |> (&(elem(&1, 0) ++ [elem(&1, 1)])).()
                        |> Enum.map(
                             fn ({k, v}) -> "#{String.downcase(Atom.to_string(k))}:#{String.downcase(v)}\n" end
                           )
    canonical_request =
      [verb, resource, query_string, canonical_headers, signed_headers, "UNSIGNED-PAYLOAD"]
      |> Enum.join("\n")

    :crypto.hash(:sha256, canonical_request)
    |> Base.encode16()
    |> String.downcase()
  end

  defp create_signed_headers(headers), do: headers
                                           |> Keyword.keys()
                                           |> Enum.sort
                                           |> Enum.join(";")

  defp generate_signature(string, client) do
    private_key = get_private_key(client)

    string
    |> :public_key.sign(:sha256, private_key, rsa_padding: :rsa_pkcs1_padding)
    |> Base.encode16()
    |> String.downcase()
  end

  defp get_private_key(client) do
    client.private_key
    |> :public_key.pem_decode()
    |> (fn [x] -> x end).()
    |> :public_key.pem_entry_decode()
  end

  def group_concat({k, v}, {acc_k, acc_v}) do
    case k do
      ^acc_k -> {[{k, "#{acc_v},#{v}"}], {nil, nil}}
      _ -> {[], {k, v}}
    end
  end
end
