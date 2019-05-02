defmodule Challenge.AccounTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Challenge.Account
  alias Challenge.Repo

  test "insert the account in database" do
    hash = %{email: "new_email@email.com", encrypted_password: "1234"}

    # Invoke the plug
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

  test "does not insert the account in database but return humanized errors" do
    hash = %{email: "no_pass@email.com"}

    {_result, record} = Account.sign_up(hash)
    parsed_errors = Account.changeset_error_to_string(record)

    assert parsed_errors == %{encrypted_password: ["can't be blank"]}
  end
end
