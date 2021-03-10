defmodule SlMillan.Helpers.SalesloftApiHelperTest do
  use ExUnit.Case, async: true
  import Mox
  setup :verify_on_exit!

  alias SlMillan.Helpers.SalesloftApiHelper

  test "valid do_get!/2 request"  do
    SlMillan.APIMock
		|> expect(:call, fn %{url: _some_url}, _opts ->
			{:ok, %Tesla.Env{status: 200, body: %{some: "data"}}}
		end)

		assert %{some: "data"} === SalesloftApiHelper.do_get!("/v2/magicapi")
  end

  test "unauthorized do_get!/2 request" do
    SlMillan.APIMock
    |> expect(:call, fn %{url: _some_url}, _opts ->
      {:ok, %Tesla.Env{status: 401}}
    end)

    assert_raise RuntimeError, "Invalid SalesLoft API Key", fn ->
      SalesloftApiHelper.do_get!("/v2/evilapi")
    end
  end
end
