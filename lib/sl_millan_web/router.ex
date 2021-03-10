defmodule SlMillanWeb.Router do
  use SlMillanWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SlMillanWeb do
    pipe_through :browser

    get "/", PeopleController, :index
    get "/counter", PeopleController, :counter
    get "/:id/duplicates", PeopleController, :duplicates
  end

  # Other scopes may use custom stacks.
  # scope "/api", SlMillanWeb do
  #   pipe_through :api
  # end
end
