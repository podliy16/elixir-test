defmodule Github.Parser.Lib do
  @enforce_keys [:name, :description, :link]
  defstruct @enforce_keys
end

defmodule Github.Parser.CategoryWithLibs do
  @enforce_keys [:name, :description, :libs]
  defstruct @enforce_keys
end

defmodule Github.Parser do

  def parse_readme({:ok, readme}) do
    parsed_data = readme
      |> String.split("\n")
      |> Earmark.Parser.parse_markdown
      |> elem(0)
      |> Enum.drop_while(&drop_until_libs/1)
      |> Enum.chunk_every(3)
      |> parse_libs_chunks
      |> Enum.take(1)

    {:ok, parsed_data}
  end

  def parse_readme({:error, error_message}), do: {:error, error_message}

  defp parse_libs_chunks(blocks) do
    for [
      %Earmark.Block.Heading{content: category_name},
      %Earmark.Block.Para{lines: [category_description]},
      %Earmark.Block.List{blocks: libs}
    ] <- blocks do
      libs = for %{blocks: [%{lines: [line]}]} <- libs, do: parse_line(line)
      %Github.Parser.CategoryWithLibs{
        name: category_name, description: category_description, libs: libs
      }
    end
  end

  defp drop_until_libs(%{level: 2}), do: false
  defp drop_until_libs(_), do: true

  @line_regex ~r/^\[([^]]+)\]\(([^)]+)\) - (.+)([\.\!]+)$/
  defp parse_line(line) do
    [^line, name, link, description, _dot] = Regex.run @line_regex, line
    %Github.Parser.Lib{name: name, link: link, description: description}
  end

end
