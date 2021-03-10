defmodule SlMillan.PeopleTest do
  use ExUnit.Case, async: true
  import Mox
  setup :verify_on_exit!

  alias SlMillan.{People, Person}
  alias SlMillan.Helpers.Tools

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

  test "list_people/2 returns a list of People" do
    SlMillan.APIMock
    |> expect(:call, fn %{url: _some_url}, _opts ->
      {:ok,
       %Tesla.Env{
         status: 200,
         body: %{data: [sales_loft_v2_person_fixture(), sales_loft_v2_person_fixture()]}
       }}
    end)

    people = People.list_people()
    first_person = List.first(people)

    assert length(people) === 2
    assert first_person.__struct__ === Person
  end

  @page 5
  @page_size 10

  test "list_people/2 returns a list of People and is paging" do
    SlMillan.APIMock
    |> expect(:call, fn %{url: _some_url, query: query_params}, _opts ->
      assert Keyword.has_key?(query_params, :page)
      assert Keyword.has_key?(query_params, :per_page)
      assert query_params[:page] === @page
      assert query_params[:per_page] === @page_size

      {:ok,
       %Tesla.Env{
         status: 200,
         body: %{data: [sales_loft_v2_person_fixture(), sales_loft_v2_person_fixture()]}
       }}
    end)

    People.list_people(@page, @page_size)
  end

  test "count_person/2 returns the correct number of characters" do
    SlMillan.APIMock
    |> expect(:call, fn %{url: _some_url}, _opts ->
      {:ok, %Tesla.Env{status: 200, body: %{data: [sales_loft_v2_person_fixture()]}}}
    end)

    people = People.list_people()
    first_person = List.first(people)

    char_count = People.count_person_letters(first_person, :email_address)

    # sakatius@gmail.com
    assert char_count.s === 2
    assert char_count.a === 3
  end
end
