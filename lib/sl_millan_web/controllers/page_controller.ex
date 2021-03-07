defmodule SlMillanWeb.PageController do
  use SlMillanWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
