defmodule Challenge.TransactionTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Challenge.Account
  alias Challenge.Repo
  alias Challenge.Transaction

  test "insert the withdrawal in database" do
    origin = Repo.get Account, 1
    value = Decimal.new("123")
    hash = %{value: value, origin_id: origin.id}

    # Create the account
    {result, record} = Transaction.withdrawal(hash)

    # Find the created account
    created_transaction = Repo.get_by Transaction, %{value: value, origin_id: origin.id}

    assert result == :ok
    assert record == created_transaction
    assert created_transaction.origin_id == origin.id
    assert created_transaction.destination_id == nil
  end

  test "insert the transaction in database" do
    origin = Repo.get Account, 2
    destination = Repo.get Account, 2
    value = Decimal.new("123")
    hash = %{value: value, origin_id: origin.id, destination_id: destination.id}

    # Create the account
    {result, record} = Transaction.transfer(hash)

    # Find the transaction
    created_transaction = Repo.get_by Transaction, %{value: value, origin_id: origin.id, destination_id: destination.id}

    assert result == :ok
    assert record == created_transaction
    assert created_transaction.origin_id == origin.id
    assert created_transaction.destination_id == destination.id
  end
end
