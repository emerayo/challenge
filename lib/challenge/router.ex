defmodule Challenge.Router do
  @moduledoc """
  A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """

  alias Challenge.Account
  alias Plug.Adapters.Cowboy

  use Plug.Router
  require Logger

  plug Plug.Logger
  # NOTE: The line below is only necessary if you care about parsing JSON
  plug Plug.Parsers, parsers: [:json], json_decoder: Poison
  plug :match
  plug :dispatch

  def init(options) do
    options
  end

  def start_link do
    port = Application.fetch_env!(:challenge, :port)
    {:ok, _} = Cowboy.http(__MODULE__, [], port: port)
  end

  # A simple route to test that the server is up
  # Note, all routes must return a connection as per the Plug spec.
  get "/" do
    render_json(conn, 200, %{response: "Welcome to our Bank API"})
  end

  # Handle incoming events, if the payload is the right shape, process the
  # events, otherwise return an error.
  post "/sign_up" do
    {status, body} =
      case conn.body_params do
        %{"email" => email, "password" => password} -> sing_up(email, password)
        _ -> {422, missing_account()}
      end

    send_resp(conn, status, body)
  end

  defp sing_up(email, password) do
    hash = %{email: email, encrypted_password: password}
    {status, body} =
      case Account.sign_up(hash) do
        {:ok, record}       -> {201, %{response: "Account created, the number is #{record.id}"}}
        {:error, changeset} -> {404, %{errors: Account.changeset_error_to_string(changeset)}}
      end

    {status, Poison.encode!(body)}
  end

  defp missing_account do
    Poison.encode!(%{error: "Expected Payload: { 'account': {...} }"})
  end

  defp render_json(conn, status, data) do
    body = Poison.encode!(data)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp((status || 200), body)
  end

  # A catchall route, 'match' will match no matter the request method,
  # so a response is always returned, even if there is no route to match.
  match _ do
    render_json(conn, 404, %{error: "oops... Nothing here"})
  end
end
