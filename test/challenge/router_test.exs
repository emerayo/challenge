defmodule Challenge.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Challenge.Account
  alias Challenge.Repo
  alias Challenge.Router

  @opts Challenge.Router.init([])

  # Basic auth header for user created in test/test_seeds.exs
  # Basic YWRtaW5AYmFua2FwaS5jb206MTIzNA==

  test "it returns the welcome message" do
    # Create a test connection
    conn = conn(:get, "/")
    |> put_req_header("authorization", "Basic YWRtaW5AYmFua2FwaS5jb206MTIzNA==")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == Poison.encode!(%{response: "Welcome to our Bank API"})
  end

  test "it returns 200 with a valid payload" do
    # Create a test connection
    conn = conn(:post, "/v1/sign_up", %{email: "email@email.com", password: "1234"})
    |> put_req_header("authorization", "Basic YWRtaW5AYmFua2FwaS5jb206MTIzNA==")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Find the created account
    created_account = Repo.get_by Account, %{email: "email@email.com", encrypted_password: "1234"}

    # Assert the response
    assert conn.status == 201
    assert conn.resp_body == Poison.encode!(%{response: "Account created, the number is #{created_account.id}"})
  end

  test "it returns 422 with an blank payload" do
    # Create a test connection
    conn = conn(:post, "/v1/sign_up", %{})
    |> put_req_header("authorization", "Basic YWRtaW5AYmFua2FwaS5jb206MTIzNA==")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response
    assert conn.status == 422
    assert conn.resp_body == Poison.encode!(%{error: "Expected Payload: { 'email': '', 'password': '' }"})
  end

  test "it returns 422 with non unique email" do
    hash = %{email: "123@email.com", encrypted_password: "1234"}

    Account.sign_up(hash)

    # Create a test connection
    conn = conn(:post, "/v1/sign_up", %{email: "123@email.com", password: "1234"})
    |> put_req_header("authorization", "Basic YWRtaW5AYmFua2FwaS5jb206MTIzNA==")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    assert conn.status == 422
    assert conn.resp_body == Poison.encode!(%{errors: %{email: ["has already been taken"]}})
  end

  test "it returns 404 when no route matches" do
    # Create a test connection
    conn = conn(:get, "/v1/fail")
    |> put_req_header("authorization", "Basic YWRtaW5AYmFua2FwaS5jb206MTIzNA==")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response
    assert conn.status == 404
  end

  test "it returns 401 when no correct auth is sent" do
    # Create a test connection
    conn = conn(:get, "/")
    |> put_req_header("authorization", "Basic YWRtaW46YWRtaW4=")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response
    assert conn.status == 401
    assert conn.resp_body == Poison.encode!(%{error: "Unauthorized"})
  end
end
