defmodule Challenge.RepoTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Challenge.Account
  alias Challenge.Repo
  alias Challenge.Transaction

  describe "account errors" do
    test "does not insert the account in database but return humanized errors" do
      hash = %{email: "no_pass@email.com"}

      {_result, record} = Account.sign_up(hash)
      parsed_errors = Repo.changeset_error_to_string(record)

      assert parsed_errors == %{encrypted_password: ["can't be blank"]}
    end

    test "does not insert the account in database with same email" do
      hash = %{email: "unique_email@email.com", encrypted_password: "1234"}
      Account.sign_up(hash)

      {_result, record} = Account.sign_up(hash)
      parsed_errors = Repo.changeset_error_to_string(record)

      assert parsed_errors == %{email: ["has already been taken"]}
    end
  end

  describe "transaction errors" do
    test "does not insert the account in database but return humanized errors" do
      origin = Repo.get Account, 1
      hash = %{value: Decimal.new("1123"), origin_id: origin.id}

      {_result, record} = Transaction.withdrawal(hash, origin)
      parsed_errors = Repo.changeset_error_to_string(record)

      assert parsed_errors == %{value: ["invalid value, should be less than balance $1000"]}
    end
  end
end
