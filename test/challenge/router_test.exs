defmodule Challenge.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Challenge.Account
  alias Challenge.Repo
  alias Challenge.Router
  alias Challenge.Transaction

  @opts Challenge.Router.init([])

  # Basic auth header for user created in test/test_seeds.exs
  # Basic YWRtaW5AYmFua2FwaS5jb206MTIzNA==

  describe "GET home" do
    test "it returns the welcome message" do
      # Create a test connection
      conn = conn(:get, "/")

      # Invoke the plug
      conn = Router.call(conn, @opts)

      # Assert the response and status
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body == Poison.encode!(%{response: "Welcome to our Bank API. Check our API documentation to learn about: https://documenter.getpostman.com/view/7390087/S1LvX9HK"})
    end
  end

  describe "POST sign_up" do
    test "it returns 201 with a valid payload" do
      # Create a test connection
      conn = conn(:post, "/v1/sign_up", %{email: "email@email.com", password: "1234"})

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

      # Invoke the plug
      conn = Router.call(conn, @opts)

      assert conn.status == 422
      assert conn.resp_body == Poison.encode!(%{errors: %{email: ["has already been taken"]}})
    end
  end

  describe "POST withdrawal" do
    test "it returns 201 with an blank payload" do
      # Create a test connection
      conn = conn(:post, "/v1/withdrawal", %{value: "321"})
      |> put_req_header("authorization", "Basic YWRtaW5AYmFua2FwaS5jb206MTIzNA==")

      # Invoke the plug
      conn = Router.call(conn, @opts)

      # Assert the response
      assert conn.status == 201
      assert conn.resp_body == Poison.encode!(%{response: "Withdrawal successful"})
    end

    test "it returns 422 with an blank payload" do
      # Create a test connection
      conn = conn(:post, "/v1/withdrawal", %{})
      |> put_req_header("authorization", "Basic YWRtaW5AYmFua2FwaS5jb206MTIzNA==")

      # Invoke the plug
      conn = Router.call(conn, @opts)

      # Assert the response
      assert conn.status == 422
      assert conn.resp_body == Poison.encode!(%{error: "Expected Payload: { 'value': '123' }"})
    end

    test "it returns 422 with a value bigger than balance" do
      %Account{email: "new_balance1@user.com", encrypted_password: "4321"} |> Repo.insert()
      # Create a test connection
      conn = conn(:post, "/v1/withdrawal", %{value: "3321"})
      |> put_req_header("authorization", "Basic bmV3X2JhbGFuY2UxQHVzZXIuY29tOjQzMjE=")

      # Invoke the plug
      conn = Router.call(conn, @opts)

      # Assert the response
      assert conn.status == 422
      assert conn.resp_body == Poison.encode!(%{errors: %{value: ["invalid value, should be less than balance $1000"]}})
    end
  end

  describe "POST transfer" do
    test "it returns 201 with an blank payload" do
      {_result, account} = %Account{email: "new_transfer1@user.com", encrypted_password: "4321"} |> Repo.insert()
      # Create a test connection
      conn = conn(:post, "/v1/transfer", %{value: "321", destination: account.id})
      |> put_req_header("authorization", "Basic YWRtaW5AYmFua2FwaS5jb206MTIzNA==")

      # Invoke the plug
      conn = Router.call(conn, @opts)

      # Assert the response
      assert conn.status == 201
      assert conn.resp_body == Poison.encode!(%{response: "Transfer successful"})
    end

    test "it returns 422 with an blank payload" do
      # Create a test connection
      conn = conn(:post, "/v1/transfer", %{})
      |> put_req_header("authorization", "Basic YWRtaW5AYmFua2FwaS5jb206MTIzNA==")

      # Invoke the plug
      conn = Router.call(conn, @opts)

      # Assert the response
      assert conn.status == 422
      assert conn.resp_body == Poison.encode!(%{error: "Expected Payload: { 'value': '123', 'destination': '1' }"})
    end

    test "it returns 422 with a value bigger than balance" do
      %Account{email: "new_transfer2@user.com", encrypted_password: "4321"} |> Repo.insert()
      {_result, destination} = %Account{email: "new_transfer3@user.com", encrypted_password: "4321"} |> Repo.insert()
      # Create a test connection
      conn = conn(:post, "/v1/transfer", %{value: "3321", destination: destination.id})
      |> put_req_header("authorization", "Basic bmV3X3RyYW5zZmVyMkB1c2VyLmNvbTo0MzIx")

      # Invoke the plug
      conn = Router.call(conn, @opts)

      # Assert the response
      assert conn.status == 422
      assert conn.resp_body == Poison.encode!(%{errors: %{value: ["invalid value, should be less than balance $1000"]}})
    end

    test "it returns 422 with same destination as origin" do
      account = Repo.get_by Account, %{email: "admin@bankapi.com", encrypted_password: "1234"}
      # Create a test connection
      conn = conn(:post, "/v1/transfer", %{value: "3321", destination: account.id})
      |> put_req_header("authorization", "Basic YWRtaW5AYmFua2FwaS5jb206MTIzNA==")

      # Invoke the plug
      conn = Router.call(conn, @opts)

      # Assert the response
      assert conn.status == 422
      assert conn.resp_body == Poison.encode!(%{errors: %{destination: ["invalid value, you can not transfer to yourself"]}})
    end
  end

  describe "GET report" do
    test "it returns 200 and sum equal zero when no transaction is in database" do
      # Remove all transactions
      Repo.delete_all(Transaction)

      # Create a test connection
      conn = conn(:get, "/v1/report")
      |> put_req_header("authorization", "Basic YWRtaW5AYmFua2FwaS5jb206MTIzNA==")

      # Invoke the plug
      conn = Router.call(conn, @opts)

      # Assert the response
      assert conn.status == 200
      assert conn.resp_body == Poison.encode!(%{response: "Sum of all transactions is: 0"})
    end

    test "it returns 200 and the sum when there are transactions in database" do
      # Remove all transactions
      Repo.delete_all(Transaction)

      # Create transaction
      origin = Repo.get Account, 2
      value = Decimal.new("123")
      %Transaction{value: value, origin_id: origin.id} |> Repo.insert!()

      # Create a test connection
      conn = conn(:get, "/v1/report")
      |> put_req_header("authorization", "Basic YWRtaW5AYmFua2FwaS5jb206MTIzNA==")

      # Invoke the plug
      conn = Router.call(conn, @opts)

      # Assert the response
      assert conn.status == 200
      assert conn.resp_body == Poison.encode!(%{response: "Sum of all transactions is: 123"})
    end

    test "it returns 401 for non admin acount" do
      # Create a test connection
      conn = conn(:get, "/v1/report")
      |> put_req_header("authorization", "Basic dXNlckB1c2Vycy5jb206NDMyMQ==")

      # Invoke the plug
      conn = Router.call(conn, @opts)

      # Assert the response
      assert conn.status == 401
      assert conn.resp_body == Poison.encode!(%{error: "Unauthorized"})
    end
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
    conn = conn(:get, "/v1/withdrawal")
    |> put_req_header("authorization", "Basic YWRtaW46YWRtaW4=")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response
    assert conn.status == 401
    assert conn.resp_body == Poison.encode!(%{error: "Unauthorized. Check our API documentation to learn about: https://documenter.getpostman.com/view/7390087/S1LvX9HK"})
  end
end
