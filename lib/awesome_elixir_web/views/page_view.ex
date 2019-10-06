defmodule AwesomeElixirWeb.PageView do
  use AwesomeElixirWeb, :view

  def last_commit_in_days(lib) do
    NaiveDateTime.utc_now()
      |> NaiveDateTime.diff(lib.last_commit_at)
      |> Integer.floor_div(60 * 60 * 24)
  end

  def lib_class(lib) do
    if (last_commit_in_days(lib) > 365) do
      "outdated"
    else
      ""
    end
  end
end
