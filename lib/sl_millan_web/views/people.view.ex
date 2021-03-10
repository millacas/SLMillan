defmodule SlMillanWeb.PeopleView do
  use SlMillanWeb, :view
  alias SlMillan.Helpers.TimeHelper

  def friendly_time(date_time) do
    TimeHelper.friendly_time(date_time)
  end
end
