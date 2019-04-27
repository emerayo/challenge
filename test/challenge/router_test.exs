defmodule Challenge.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Challenge.{Router, Router}

  @opts Challenge.Router.init([])

  test "it returns the welcome message" do
    # Create a test connection
    conn = conn(:get, "/")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == Poison.encode!(%{response: "Welcome to our Bank API"})
  end

  test "it returns 200 with a valid payload" do
    # Create a test connection
    conn = conn(:post, "/sign_up", %{account: %{}})

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response
    assert conn.status == 200
    assert conn.resp_body == Poison.encode!(%{response: "Received account!"})
  end

  test "it returns 422 with an invalid payload" do
    # Create a test connection
    conn = conn(:post, "/sign_up", %{})

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response
    assert conn.status == 422
    assert conn.resp_body == Poison.encode!(%{error: "Expected Payload: { 'account': {...} }"})
  end

  test "it returns 404 when no route matches" do
    # Create a test connection
    conn = conn(:get, "/fail")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response
    assert conn.status == 404
  end
end