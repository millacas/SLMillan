defmodule SlMillan.Person do
  @moduledoc """
  This module is used to normalize the Person object from the SalesLoft API V2.
  """
  alias __MODULE__

  @type t :: %__MODULE__{
          id: integer(),
          created_at: DateTime.t(),
          updated_at: DateTime.t(),
          last_contacted_at: DateTime.t(),
          last_replied_at: DateTime.t(),
          first_name: String.t(),
          last_name: String.t(),
          display_name: String.t(),
          email_address: String.t(),
          full_email_address: String.t(),
          secondary_email_address: String.t(),
          personal_email_address: String.t(),
          phone: String.t(),
          phone_extension: String.t(),
          home_phone: String.t(),
          mobile_phone: String.t(),
          linkedin_url: String.t(),
          title: String.t(),
          person_company_name: String.t(),
          locale: String.t()
        }

  defstruct [
    :id,
    :created_at,
    :updated_at,
    :last_contacted_at,
    :last_replied_at,
    :first_name,
    :last_name,
    :display_name,
    :email_address,
    :full_email_address,
    :secondary_email_address,
    :personal_email_address,
    :phone,
    :phone_extension,
    :home_phone,
    :mobile_phone,
    :linkedin_url,
    :title,
    :person_company_name,
    :locale
  ]

  @date_fields [
    :created_at,
    :updated_at,
    :last_contacted_at,
    :last_replied_at
  ]

  @doc """
  Creates a `Person` struct from a map.
  `person_data` receive a map with all the person data. It's important that all the keys on the `person_data` map are atoms.

  ## Examples

  	iex> encode(%{display_name: "Jermey Bruen", updated_at: "2020-01-20T04:46:19.961197-05:00"})
  	%Person{
  		display_name: "Jermey Bruen",
  		updated_at: ~U[2020-01-20 09:46:19.961197Z]
  	}

  """
  @spec encode(person_data :: map()) :: Person.t()
  def encode(person_data) do
    encoded_person_data =
      person_data
      |> Enum.map(&maybe_encode_field/1)
      |> Map.new()

    struct(__MODULE__, encoded_person_data)
  end

  defp maybe_encode_field(no_encode_needed = {_key, nil}), do: no_encode_needed
  defp maybe_encode_field(no_encode_needed = {_key, ""}), do: no_encode_needed

  defp maybe_encode_field({key, value_to_encode}) when key in @date_fields do
    {_ok, encoded_utc_datetime, _offset} = DateTime.from_iso8601(value_to_encode)
    {key, encoded_utc_datetime}
  end

  defp maybe_encode_field(no_encode_needed), do: no_encode_needed
end
