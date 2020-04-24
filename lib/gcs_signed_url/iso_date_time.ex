defmodule GcsSignedUrl.ISODateTime do
  @moduledoc """
  Generates timestamps formatted in iso8601 for usage in signature generation.
  """

  @type t :: %__MODULE__{
               date: String.t(),
               datetime: String.t()
             }

  @fields [
    :date,
    :datetime
  ]
  @enforce_keys @fields
  defstruct @fields

  @doc """
  Generates a GcsSignedUrl.DateTime struct from the given timestamp. If no timestamp is given, current time is used.
  """
  @spec generate(DateTime.t()) :: __MODULE__.t()
  @spec generate() :: __MODULE__.t()
  def generate(date_time) do
    {:ok, date_time} = DateTime.shift_zone(date_time, "Etc/UTC")
    date_time = DateTime.truncate(date_time, :second)
    iso_date_time = DateTime.to_iso8601(date_time, :basic)
    iso_date = date_time
           |> DateTime.to_date()
           |> Date.to_iso8601(:basic)

    %__MODULE__{
      date: iso_date,
      datetime: iso_date_time,
    }
  end
  def generate(), do: generate(DateTime.utc_now())
end
