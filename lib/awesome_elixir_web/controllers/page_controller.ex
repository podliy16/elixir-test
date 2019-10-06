defmodule AwesomeElixirWeb.PageController do
  use AwesomeElixirWeb, :controller
  import Ecto.Query
  alias AwesomeElixir.Ecto.{Category, Lib}

  def index(conn, params) do
    min_stars = params["min_stars"] || 0
    libs_query = from l in Lib, where: l.stars_count > ^min_stars, order_by: l.name
    category_with_libs =
      AwesomeElixir.Repo.all(from c in Category, preload: [libs: ^libs_query], order_by: c.name)
      |> Enum.filter(fn c -> length(c.libs) > 0 end)
    render(conn, "index.html", category_with_libs: category_with_libs)
  end
end
