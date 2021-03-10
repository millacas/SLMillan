defmodule SlMillan.Helpers.SalesloftApiHelper do
  @moduledoc """
  Helper with all the logic needed for requesting data from SalesLoft API V2
  """

  use Tesla

  plug Tesla.Middleware.BaseUrl,
       Application.get_env(:sl_millan, :sl_api)[:api_base_url]

  plug Tesla.Middleware.JSON,
    engine: Jason,
    engine_opts: [keys: :atoms]

  plug Tesla.Middleware.Headers,
       [
         {
           "Authorization",
           "Bearer " <> Application.get_env(:sl_millan, :sl_api)[:api_key]
         }
       ]

  plug Tesla.Middleware.Retry,
    delay: 500,
    max_retries: 4,
    max_delay: 4_000,
    should_retry: fn
      {:ok, %{status: status}} when status not in [200, 401, 403, 404, 422] -> true
      {:ok, _response} -> false
      {:error, _error} -> true
    end

  @doc """
  Request GET a given `resource` with the given `query_params`

  ## Example

  		iex> do_get!("/v2/people.json", [include_paging_counts: true])
  		%{}

  """
  @spec do_get!(resource :: String.t(), query_params :: keyword()) :: map()
  def do_get!(resource, query_params \\ []) when is_list(query_params) do
    get(resource, query: query_params)
    |> validate_response!()
  end

  defp validate_response!({:ok, %{status: 200, body: body}}), do: body

  defp validate_response!({:ok, %{status: 403, body: %{error: error}}}) do
    IO.inspect(error)
    raise "Api error"
  end

  defp validate_response!({:ok, %{status: status, body: %{errors: errors}}})
       when status in [404, 422] do
    IO.inspect(errors)
    raise "Api error"
  end

  defp validate_response!({:ok, %{status: 401}}) do
    raise "Invalid SalesLoft API Key"
  end

  defp validate_response!(_response), do: raise("Unknown error")
end
