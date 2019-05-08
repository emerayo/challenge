defmodule Challenge.TransactionTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Challenge.Account
  alias Challenge.Repo
  alias Challenge.Transaction

  describe "withdrawal" do
    test "insert a withdrawal in database" do
      origin = Repo.get Account, 1
      value = Decimal.new("123")
      hash = %{value: value, origin_id: origin.id}

      # Create the transaction
      {result, record} = Transaction.withdrawal(hash, origin)

      # Find the created transaction
      created_transaction = Repo.get_by Transaction, %{value: value, origin_id: origin.id}

      assert result == :ok
      assert record == created_transaction
      assert created_transaction.origin_id == origin.id
      assert created_transaction.destination_id == nil
    end

    test "pass a grater number than balance to withdrawal in database" do
      origin = Repo.get Account, 1
      value = Decimal.new("1123")
      hash = %{value: value, origin_id: origin.id}

      # Create the transaction
      {result, record} = Transaction.withdrawal(hash, origin)

      # Find the created transaction
      created_transaction = Repo.get_by Transaction, %{value: value, origin_id: origin.id}

      assert result == :error
      assert record.errors == [value: {"invalid value, should be less than value", []}]
    end
  end

  describe "transfer" do
    test "insert a transfer in database" do
      origin = Repo.get Account, 2
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
      origin = Repo.get Account, 2
      destination = Repo.get Account, 2
      value = Decimal.new("2222")
      hash = %{value: value, origin_id: origin.id, destination_id: destination.id}

      # Create the transaction
      {result, record} = Transaction.transfer(hash, origin)

      # Find the created transaction
      created_transaction = Repo.get_by Transaction, %{value: value, origin_id: origin.id, destination_id: destination.id}

      assert result == :error
      assert record.errors == [value: {"invalid value, should be less than value", []}]
    end
  end
end
