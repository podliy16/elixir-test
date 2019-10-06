defmodule Github.Parser.Lib do
  @moduledoc false
  @type t :: %__MODULE__{
    name: String.t,
    description: String.t,
    link: String.t
  }
  @enforce_keys [:name, :description, :link]
  defstruct @enforce_keys
end

defmodule Github.Parser.LibInfo do
  @moduledoc false
  @type t :: %__MODULE__{
    stars_count: integer,
    last_commit_at: NaiveDateTime.t
  }
  @enforce_keys [:stars_count, :last_commit_at]
  defstruct @enforce_keys
end

defmodule Github.Parser.CategoryWithLibs do
  @moduledoc false
  @type t :: %__MODULE__{
    name: String.t,
    description: String.t,
    libs: [Github.Parser.Lib.t]
  }

  @enforce_keys [:name, :description, :libs]
  defstruct @enforce_keys
end

defmodule Github.Parser do
  @moduledoc """
    Parse raw github reponses to understandable structs.
  """

  @spec parse_readme(String.t) :: {:ok, [Github.Parser.CategoryWithLibs.t]}
  def parse_readme(readme) do
    parsed_data = readme
      |> String.split("\n")
      |> Earmark.Parser.parse_markdown
      |> elem(0)
      |> Enum.drop_while(&drop_until_libs/1)
      |> Enum.chunk_every(3)
      |> parse_libs_chunks

    {:ok, parsed_data}
  end

  @spec parse_repo_response(String.t) :: {:ok, Github.Parser.LibInfo.t} | {:error, :notfound}
  def parse_repo_response(repo_json_string) do
    case Poison.decode!(repo_json_string) |> get_in(["data", "repository"]) do
      nil -> {:error, :notfound}
      repo_json -> get_data_from_repo_json(repo_json)
    end
  end

  @spec get_data_from_repo_json(map) :: {:ok, Github.Parser.LibInfo.t}
  defp get_data_from_repo_json(repo_json) do
    stars_count = repo_json["stargazers"]["totalCount"]
    last_commit = repo_json
      |> get_in(["defaultBranchRef", "target", "history", "edges"])
      |> Enum.at(0)
      |> get_in(["node", "committedDate"])
      |> NaiveDateTime.from_iso8601!
    {:ok, %Github.Parser.LibInfo{stars_count: stars_count, last_commit_at: last_commit}}
  end

  @spec parse_libs_chunks(any) :: [Github.Parser.CategoryWithLibs.t]
  defp parse_libs_chunks(blocks) do
    for [
      %Earmark.Block.Heading{content: category_name},
      %Earmark.Block.Para{lines: [category_description]},
      %Earmark.Block.List{blocks: libs}
    ] <- blocks do
      libs = for %{blocks: [%{lines: [line]}]} <- libs, do: parse_line(line)
      libs = Enum.filter(libs, &match?(%Github.Parser.Lib{}, &1))
      %Github.Parser.CategoryWithLibs{
        name: category_name, description: category_description, libs: libs
      }
    end
  end

  defp drop_until_libs(%{level: 2}), do: false
  defp drop_until_libs(_), do: true

  defp parse_line(line) do
    line_regex = ~r/^\[([^]]+)\]\((https:\/\/github[^\)]+)\) - (.+)([\.\!]+)$/
    case Regex.run(line_regex, line) do
      [^line, name, link, description, _dot] -> %Github.Parser.Lib{name: name, link: link, description: description}
      _ -> {:error, :line_regex_failed}
    end

  end

end
