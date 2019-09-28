defmodule Github.Fetcher do

  @url "https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md"
  def get_file(url) do
    case HTTPoison.get(url) do
      {
        :ok,
        %HTTPoison.Response{status_code: 200, body: body}
      } -> {:ok, body}
      {
        :ok,
        %HTTPoison.Response{status_code: status_code}
      } -> {:error, "Failed with status code #{status_code}"}
      {
        :error,
        %HTTPoison.Error{reason: reason}
      } -> {:error, "Failed with error #{reason}"}
    end
  end

end
