defmodule AwesomeElixir.Factory do

  @moduledoc false

  def build_parser_lib(link) do
    %Github.Parser.Lib{
      name: "name",
      description: "decsription",
      link: link
    }
  end

  def build_parser_category(libs) do
    %Github.Parser.CategoryWithLibs{
      description: "description",
      name: "name",
      libs: libs
    }
  end

end
