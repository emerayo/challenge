defmodule Challenge.HomePlug do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, welcome_message())
  end

  defp welcome_message do
    Poison.encode!(%{response: "Welcome to our Bank API"})
  end
end
