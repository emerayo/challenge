defmodule Challenge.Router do
  @moduledoc """
  A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """

  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)

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
        %{"account" => account} -> {200, sing_up(account)}
        _ -> {422, missing_account()}
      end

    send_resp(conn, status, body)
  end

  defp sing_up(account) do
    # Do some processing on a list of events
    Poison.encode!(%{response: "Received account!"})
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
