defmodule SlMillan.PersonTest do
  use ExUnit.Case, async: true

  alias SlMillan.Person
  alias SlMillan.Helpers.Tools

  @valid_person %Person{
    created_at: ~U[2020-01-10 20:44:04.134541Z],
    display_name: "Steven Pease",
    email_address: "sakatius@gmail.com",
    first_name: "Steven",
    full_email_address: "\"Steven Pease\" <sakatius@gmail.com>",
    home_phone: nil,
    id: 249_340_741,
    last_contacted_at: nil,
    last_name: "Pease",
    last_replied_at: nil,
    linkedin_url: nil,
    locale: "US/Eastern",
    mobile_phone: nil,
    person_company_name: nil,
    personal_email_address: "sakatius@gmail.com",
    phone: "7702354590",
    phone_extension: nil,
    secondary_email_address: "sakatius@gmail.com",
    title: "Software Engineer",
    updated_at: ~U[2020-01-20 09:46:19.961197Z],
    extra: nil
  }

  @sales_loft_v2_person %{
    "id" => 249_340_741,
    "created_at" => "2020-01-10T15:44:04.134541-05:00",
    "updated_at" => "2020-01-20T04:46:19.961197-05:00",
    "last_contacted_at" => nil,
    "last_replied_at" => nil,
    "first_name" => "Steven",
    "last_name" => "Pease",
    "display_name" => "Steven Pease",
    "email_address" => "sakatius@gmail.com",
    "full_email_address" => "\"Steven Pease\" <sakatius@gmail.com>",
    "secondary_email_address" => "sakatius@gmail.com",
    "personal_email_address" => "sakatius@gmail.com",
    "phone" => "7702354590",
    "phone_extension" => nil,
    "home_phone" => nil,
    "mobile_phone" => nil,
    "linkedin_url" => nil,
    "title" => "Software Engineer",
    "city" => "Atlanta",
    "state" => "GA",
    "country" => "United States",
    "work_city" => nil,
    "work_state" => nil,
    "work_country" => nil,
    "crm_url" => nil,
    "crm_id" => nil,
    "crm_object_type" => nil,
    "owner_crm_id" => nil,
    "person_company_name" => nil,
    "person_company_website" => "http://gmail.com",
    "person_company_industry" => nil,
    "do_not_contact" => true,
    "bouncing" => false,
    "locale" => "US/Eastern",
    "eu_resident" => false,
    "personal_website" => nil,
    "twitter_handle" => nil,
    "last_contacted_type" => nil,
    "job_seniority" => nil,
    "custom_fields" => %{},
    "tags" => [],
    "contact_restrictions" => [],
    "counts" => %{
      "emails_sent" => 0,
      "emails_viewed" => 0,
      "emails_clicked" => 0,
      "emails_replied_to" => 0,
      "emails_bounced" => 0,
      "calls" => 0
    },
    "account" => nil,
    "owner" => %{
      "_href" => "https://api.salesloft.com/v2/users/46818",
      "id" => 46818
    },
    "last_contacted_by" => nil,
    "import" => nil,
    "person_stage" => nil,
    "most_recent_cadence" => nil
  }

  def sales_loft_v2_person_fixture() do
    @sales_loft_v2_person
    |> Tools.keys_to_atoms()
  end

  def person_fixture() do
    @valid_person
  end

  test "encode/1 returns a Person from SalesLoft person map" do
    person = person_fixture()

    encoded_person =
      sales_loft_v2_person_fixture()
      |> Person.encode()

    assert encoded_person.__struct__ === Person
    assert person.created_at === encoded_person.created_at
    assert person.display_name === encoded_person.display_name
    assert person.email_address === encoded_person.email_address
    assert person.first_name === encoded_person.first_name
    assert person.full_email_address === encoded_person.full_email_address
    assert person.home_phone === encoded_person.home_phone
    assert person.id === encoded_person.id
    assert person.last_contacted_at === encoded_person.last_contacted_at
    assert person.last_name === encoded_person.last_name
    assert person.last_replied_at === encoded_person.last_replied_at
    assert person.linkedin_url === encoded_person.linkedin_url
    assert person.locale === encoded_person.locale
    assert person.mobile_phone === encoded_person.mobile_phone
    assert person.person_company_name === encoded_person.person_company_name
    assert person.personal_email_address === encoded_person.personal_email_address
    assert person.phone === encoded_person.phone
    assert person.phone_extension === encoded_person.phone_extension
    assert person.secondary_email_address === encoded_person.secondary_email_address
    assert person.title === encoded_person.title
    assert person.updated_at === encoded_person.updated_at
    assert person.extra === encoded_person.extra
  end
end
