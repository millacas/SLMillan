defmodule SlMillan.People do
  alias SlMillan.Person
  alias SlMillan.Helpers.SalesloftApiHelper

  @people_resource "/v2/people.json"
  @page_size 10
  @fetch_all_page_size 100
  @basic_query_params [
    sort: "updated_at",
    sort_direction: "ASC"
  ]

  @doc """
  List people in a paged maner
  list people can receive `page` and `page_size` to allow some pagination.

  If no values are given the default `page` will be 1 and `page_size` will be 10
  """
  @spec list_people(page :: integer(), page_size :: integer()) :: list(Person.t())
  def list_people(page \\ 1, page_size \\ @page_size) do
    query_params = @basic_query_params ++ [page: page, per_page: page_size]

    try do
      SalesloftApiHelper.do_get!(@people_resource, query_params)
      |> Map.get(:data, [])
      |> Enum.map(&Person.encode(&1))
    rescue
      error ->
        IO.inspect(error)
    end
  end

  @doc """
  Lists all people related to the SalesLoft account
  """
  @spec list_all_people :: list(Person.t())
  def list_all_people do
    try do
      fetch_people!([], @fetch_all_page_size)
    rescue
      error ->
        IO.inspect(error)
    end
  end

  @doc """
  Returns a person with a given `id`
  """
  @spec get_person(id :: integer()) :: Person.t() | nil
  def get_person(id) when is_integer(id) do
    query_params = @basic_query_params ++ ["ids[]": id]

    try do
      SalesloftApiHelper.do_get!(@people_resource, query_params)
      |> Map.get(:data, [])
      |> Enum.map(&Person.encode(&1))
      |> List.first()
    rescue
      error ->
        IO.inspect(error)
    end
  end

  @doc """
  Count the letters on a given list of `people` with the given `field_to_count_key`

  If the given `field_to_count_key` has no valid strings, an empty map will be returned.
  """
  @spec count_people_letters(people :: list(Person.t()), field_to_count_key :: atom()) :: map()
  def count_people_letters(people, field_to_count_key) do
    people
    |> Enum.reduce(%{}, fn person, letter_counting ->
      person
      |> count_person_letters(field_to_count_key)
      |> Map.merge(letter_counting, fn _key, value1, value2 ->
        value1 + value2
      end)
    end)
  end

  @doc """
  Count the letters on a given `Person` with the given `field_to_count_key`

  If the given `field_to_count_key` has no valid strings, an empty map will be returned.
  """
  @spec count_person_letters(person :: Person.t(), field_to_count_key :: atom()) :: map()
  def count_person_letters(person = %Person{}, field_to_count_key) do
    field_to_count = Map.get(person, field_to_count_key)

    if String.valid?(field_to_count) do
      String.downcase(field_to_count)
      |> String.split("", trim: true)
      |> Enum.reduce(%{}, fn character, acc ->
        Map.new([{String.to_atom(character), 1}])
        |> Map.merge(acc, fn _key, value1, value2 ->
          value1 + value2
        end)
      end)
    else
      # If the string is not valid, the show must go on
      %{}
    end
  end

  defmodule DuplicateMetadata do
    defstruct [
      :username,
      :username_length,
      :domain,
      :jaro_distance
    ]
  end

  @length_threshold 2
  @distance_threshold 0.85

  @doc """
  Lists the duplicate emails on a given `Person` list (`people`)
  The method receives a `target_person` and the option to define the `email_field` to look for.

  If no duplicates were found, an empty list is returned.
  """
  @spec find_email_duplicates(
          people :: list(Person.t()),
          target_person :: Person.t(),
          email_field :: atom()
        ) :: list(Person.t())
  def find_email_duplicates(people, %Person{} = target_person, email_field)
      when is_atom(email_field) do
    [target_username, _domain] =
      target_person
      |> Map.get(email_field)
      |> String.split("@")

    people
    |> assamble_email_duplicate_metadata(email_field)
    |> filter_length_threshold(target_username)
    |> map_jaro_distance(target_username)
    |> filter_distance_threshold()
    |> drop_target_person(target_person)
  end

  defp assamble_email_duplicate_metadata(people, email_field) do
    Enum.map(people, fn person ->
      email = Map.get(person, email_field)

      username =
        String.split(email, "@")
        |> List.first()

      duplicate_metadata = %DuplicateMetadata{
        username: username,
        username_length: String.length(username)
      }

      %{person | extra: duplicate_metadata}
    end)
  end

  defp filter_length_threshold(people, target_username) do
    length_threshold = build_length_threshold(target_username)

    Enum.filter(people, &(&1.extra.username_length in length_threshold))
  end

  defp build_length_threshold(target_username) do
    username_length = String.length(target_username)

    (username_length - @length_threshold)..(username_length + @length_threshold)
  end

  defp map_jaro_distance(people, target_username) do
    Enum.map(people, fn person ->
      duplicate_metadata = person.extra

      duplicate_metadata = %{
        duplicate_metadata
        | jaro_distance: String.jaro_distance(target_username, duplicate_metadata.username)
      }

      %{person | extra: duplicate_metadata}
    end)
  end

  defp filter_distance_threshold(people) do
    Enum.filter(people, &(&1.extra.jaro_distance > @distance_threshold))
  end

  defp drop_target_person(people, target_person) do
    Enum.reject(people, &(&1.id === target_person.id))
  end

  defp fetch_people!(people, fetch_size) when fetch_size === @fetch_all_page_size do
    query_params =
      List.last(people)
      |> Kernel.||(%{})
      |> Map.get(:updated_at)
      |> assamble_fetch_all_query_params()

    fetched_people =
      SalesloftApiHelper.do_get!(@people_resource, query_params)
      |> Map.get(:data, [])
      |> Enum.map(&Person.encode(&1))

    fetch_people!(people ++ fetched_people, length(fetched_people))
  end

  defp fetch_people!(people, _fetch_size), do: people

  defp assamble_fetch_all_query_params(_last_updated_at = nil) do
    @basic_query_params ++ [per_page: @fetch_all_page_size]
  end

  defp assamble_fetch_all_query_params(last_updated_at) do
    @basic_query_params ++
      [per_page: @fetch_all_page_size, "updated_at[gt]": last_updated_at |> DateTime.to_iso8601()]
  end
end
