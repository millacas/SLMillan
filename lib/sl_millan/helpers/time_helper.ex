defmodule SlMillan.Helpers.TimeHelper do
  @moduledoc """
  This module is used to manipulate dates.
  """
  @time_zone "America/Mexico_City"
  use Timex

	def friendly_time(date_time, date_time_format \\ "{Mshort}-{D}-{YY} {h24}:{m}")
	def friendly_time(date_time, _date_time_format) when is_nil(date_time), do: "-"
  def friendly_time(date_time, date_time_format) do
		date_time
    |> Timex.to_datetime(@time_zone)
    |> Timex.format!(date_time_format)
  end
end
