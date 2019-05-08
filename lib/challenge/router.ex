defmodule Challenge.Router do
  @moduledoc """
  A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """

  alias Challenge.Account
  alias Challenge.Authentication
  alias Challenge.Repo
  alias Challenge.Transaction

  use Plug.Router
  require Logger

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:json], json_decoder: Poison
  plug Authentication # run authentication
  plug :match
  plug :dispatch

  # Welcome route
  get "/" do
    render_json(conn, 200, %{response: "Welcome to our Bank API. Check our API documentation to learn about: https://documenter.getpostman.com/view/7390087/S1LvX9HK"})
  end

  # Handle the sign_up for a new account
  post "/v1/sign_up" do
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
        {:error, changeset} -> {422, %{errors: Repo.changeset_error_to_string(changeset)}}
      end

    {status, body}
  end

  defp missing_account do
    %{error: "Expected Payload: { 'email': '', 'password': '' }"}
  end

  # Handle the sign_up for a new account
  post "/v1/withdrawal" do
    account = authenticated_account(conn)
    {status, body} =
      case conn.body_params do
        %{"value" => value} -> withdrawal(value, account)
        _ -> {422, %{error: "Expected Payload: { 'value': '123' }"}}
      end

    render_json(conn, status, body)
  end

  defp authenticated_account(conn) do
    case get_req_header(conn, "authorization") do
      ["Basic " <> attempted_auth] -> Authentication.find_account(attempted_auth)
    end
  end

  defp withdrawal(value, account) do
    hash = %{value: Decimal.new(value), origin_id: account.id}
    {status, body} =
      case Transaction.withdrawal(hash, account) do
        {:ok, _record}       -> {201, %{response: "Withdrawal successful"}}
        {:error, changeset} -> {422, %{errors: Repo.changeset_error_to_string(changeset)}}
      end

    {status, body}
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
