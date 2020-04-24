defmodule GcsSignedUrl.ISODateTimeTest do
  use ExUnit.Case
  alias GcsSignedUrl.ISODateTime, as: MUT

  describe "generate/0" do
    test "returns a DateTime Struct" do
      iso_date_time = MUT.generate()
      assert MUT == iso_date_time.__struct__
    end
  end

  describe "generate/1" do
    test "returns correct data" do
      date_time = %DateTime{
        year: 2000,
        month: 2,
        day: 29,
        zone_abbr: "AMT",
        hour: 23,
        minute: 0,
        second: 7,
        microsecond: {0, 0},
        utc_offset: 7200,
        std_offset: 0,
        time_zone: "Europe/Zurich"
      }

      iso_date_time = MUT.generate(date_time)

      assert MUT == iso_date_time.__struct__
      assert "20000229T210007Z" == iso_date_time.datetime
      assert "20000229" == iso_date_time.date
    end
  end
end
