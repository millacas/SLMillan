defmodule SlMillanWeb.PeopleController do
  use SlMillanWeb, :controller
  alias SlMillan.People

  def index(conn, _params) do
    people_data =
      People.list_people()

    render(
      conn,
      :index,
      people: people_data
    )
  end

  def counter(conn, _params) do
    counted_characters =
      People.list_all_people()
      |> People.count_people_letters(:email_address)

    render(
      conn,
      :counter,
      counted_characters: counted_characters
    )
  end

  def duplicates(conn, %{"id" => id}) do
    target_person =
      String.to_integer(id)
      |> People.get_person()

    posible_duplicates =
      People.list_all_people()
      |> People.find_email_duplicates(target_person, :email_address)

    render(
      conn,
      :duplicates,
      target_person: target_person,
      posible_duplicates: posible_duplicates
    )
  end
end
