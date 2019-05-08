defmodule Challenge.Router do
  @moduledoc """
  A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """

  alias Challenge.Account
  alias Challenge.Authentication
  alias Plug.Adapters.Cowboy

  use Plug.Router
  require Logger

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:json], json_decoder: Poison
  plug Authentication # run authentication
  plug :match
  plug :dispatch

  # Welcome route
  get "/" do
    render_json(conn, 200, %{response: "Welcome to our Bank API"})
  end

  # Handle the sign_up for a new account
  post "/sign_up" do
    {status, body} =
      case conn.body_params do
        %{"email" => email, "password" => password} -> sing_up(email, password)
        _ -> {422, missing_account()}
      end

    render_json(conn, status, body)
  end

  defp sing_up(email, password) do
    hash = %{email: email, encrypted_password: password}
    {status, body} =
      case Account.sign_up(hash) do
        {:ok, record}       -> {201, %{response: "Account created, the number is #{record.id}"}}
        {:error, changeset} -> {422, %{errors: Account.changeset_error_to_string(changeset)}}
      end

    {status, body}
  end

  defp missing_account do
    %{error: "Expected Payload: { 'email': '', 'password': '' }"}
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
