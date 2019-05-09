defmodule Challenge.TransactionTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Challenge.Account
  alias Challenge.Repo
  alias Challenge.Transaction

  describe "withdrawal" do
    test "insert a withdrawal in database" do
      {_result, account} = %Account{email: "new_balance2@user.com", encrypted_password: "4321"} |> Repo.insert()
      value = Decimal.new("123")
      hash = %{value: value, origin_id: account.id}

      # Create the transaction
      {result, record} = Transaction.withdrawal(hash, account)

      # Find the created transaction
      created_transaction = Repo.get_by Transaction, %{value: value, origin_id: account.id}

      assert result == :ok
      assert record == created_transaction
      assert created_transaction.origin_id == account.id
      assert created_transaction.destination_id == nil
    end

    test "pass a grater number than balance to withdrawal in database" do
      {_result, account} = %Account{email: "new_balance3@user.com", encrypted_password: "4321"} |> Repo.insert()
      value = Decimal.new("1123")
      hash = %{value: value, origin_id: account.id}

      # Create the transaction
      {result, record} = Transaction.withdrawal(hash, account)

      assert result == :error
      assert record.errors == [value: {"invalid value, should be less than balance $1000", []}]
    end
  end

  describe "transfer" do
    test "insert a transfer in database" do
      origin = Repo.get Account, 1
      destination = Repo.get Account, 2
      value = Decimal.new("123")
      hash = %{value: value, origin_id: origin.id, destination_id: destination.id}

      # Create the transaction
      {result, record} = Transaction.transfer(hash, origin)

      # Find the transaction
      created_transaction = Repo.get_by Transaction, %{value: value, origin_id: origin.id, destination_id: destination.id}

      assert result == :ok
      assert record == created_transaction
      assert created_transaction.origin_id == origin.id
      assert created_transaction.destination_id == destination.id
    end

    test "pass a grater number than balance to withdrawal in database" do
      {_result, account} = %Account{email: "new_balance4@user.com", encrypted_password: "4321"} |> Repo.insert()
      destination = Repo.get Account, 2
      value = Decimal.new("2222")
      hash = %{value: value, origin_id: account.id, destination_id: destination.id}

      # Create the transaction
      {result, record} = Transaction.transfer(hash, account)

      assert result == :error
      assert record.errors == [value: {"invalid value, should be less than balance $1000", []}]
    end

    test "pass the same account to destination, should return error" do
      {_result, account} = %Account{email: "new_balance5@user.com", encrypted_password: "4321"} |> Repo.insert()
      value = Decimal.new("2222")
      hash = %{value: value, origin_id: account.id, destination_id: account.id}

      # Create the transaction
      {result, record} = Transaction.transfer(hash, account)

      assert result == :error
      assert record.errors == [destination: {"invalid value, you can not transfer to yourself", []}]
    end
  end

  describe "sum_all_values" do
    test "with no transactions in database" do
      Repo.delete_all(Transaction)

      result = Transaction.sum_all_values

      assert result == Decimal.new("0")
    end

    test "with transactions in database" do
      Repo.delete_all(Transaction)

      origin = Repo.get Account, 2
      value = Decimal.new("123")

      %Transaction{value: value, origin_id: origin.id} |> Repo.insert!()

      result = Transaction.sum_all_values

      assert result == value
    end
  end
end
