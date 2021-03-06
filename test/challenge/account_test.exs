defmodule Challenge.AccountTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Challenge.Account
  alias Challenge.Repo

  test "insert the account in database" do
    hash = %{email: "new_email@email.com", encrypted_password: "1234"}

    # Create the account
    {result, record} = Account.sign_up(hash)

    # Find the created account
    created_account = Repo.get_by Account, %{email: "new_email@email.com", encrypted_password: "1234"}

    assert result == :ok
    assert record == created_account
  end

  test "does not insert the account in database but return errors" do
    hash = %{email: "no_pass@email.com"}

    {result, record} = Account.sign_up(hash)

    # Search for the account
    query_result = Repo.get_by Account, %{email: "no_pass@email.com"}

    assert result == :error
    assert query_result == nil
    assert record.errors == [{:encrypted_password, {"can't be blank", [validation: :required]}}]
  end

  test "does update the account's balance" do
    new_balance = Decimal.new("333")
    {_result, account} = %Account{email: "new_balance@user.com", encrypted_password: "4321"} |> Repo.insert()

    {result, account} = Account.update_balance(account, new_balance)

    assert result == :ok
    assert account.balance == new_balance
  end
end
