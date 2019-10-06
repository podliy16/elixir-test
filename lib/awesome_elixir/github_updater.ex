defmodule AwesomeElixir.GithubUpdater do

  @moduledoc """
    Populate database from GitHub.
  """

  require Logger
  alias AwesomeElixir.Ecto.{Category}

  @spec update :: :ok
  def update do
    url = "https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md"
    Logger.info("Trying to fetch readme")

    with {:ok, response_body} <- Github.Fetcher.get_file(url),
      {:ok, parsed_data} <- Github.Parser.parse_readme(response_body)
    do
      parsed_data
        |> Enum.each(&Category.update_category_with_libs/1)
    else
      {:error, error_message} -> Logger.error(error_message)
    end

    :ok
  end

end
