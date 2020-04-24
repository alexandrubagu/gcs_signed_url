defmodule GcsSignedUrl.Headers do
  @moduledoc """
  Transforms headers for a request to representations required by the Google URL signature algorithm
  """
  @type t :: %__MODULE__{
          signed: String.t(),
          canonical: String.t()
        }

  @fields [
    :signed,
    :canonical
  ]
  @enforce_keys @fields
  defstruct @fields

  @doc """
  Creates a %GcsSignedUrl.Headers{} struct from the given headers keyword list. The struct contains the signed
  headers, such as the canonical headers

  ## Examples

      iex> GcsSignedUrl.Headers.create(["X-Foo": "foo", "X-Foo": "bar", "Content-Type": "application/json"])
      %GcsSignedUrl.Headers{signed: "content-type,x-foo", canonical:...}
  """
  @spec create(Keyword.t()) :: __MODULE__.t()
  def create(headers) do
    headers =
      headers
      |> Enum.map(fn {k, v} -> {String.downcase("#{k}"), String.replace(v, ~r/[\r\n]/, " ")} end)
      |> Enum.sort(fn {k1, _}, {k2, _} -> k1 <= k2 end)
      |> group_concat()

    %__MODULE__{
      signed: create_signed_headers(headers),
      canonical: create_canonical_headers(headers)
    }
  end

  defp create_signed_headers(headers) do
    headers
    |> Keyword.keys()
    |> Enum.join(";")
  end

  defp create_canonical_headers(headers) do
    Enum.map_join(headers, fn {k, v} -> "#{k}:#{v}\n" end)
  end

  defp group_concat(list) do
    Enum.flat_map_reduce(
      list,
      [],
      fn {k, v}, acc ->
        case acc do
          [] -> {[], [{k, v}]}
          [{^k, acc_v}] -> {[], [{k, "#{acc_v},#{v}"}]}
          _ -> {acc, [{k, v}]}
        end
      end
    )
    |> (&(elem(&1, 0) ++ elem(&1, 1))).()
  end
end
