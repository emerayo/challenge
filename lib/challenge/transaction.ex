defmodule Challenge.Transaction do
  @moduledoc """
  Schema responsible for handling an Account Transaction
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Challenge.Account
  alias Challenge.Repo
  alias Challenge.Transaction
  alias Ecto.Changeset

  schema "transactions" do
    field :value, :decimal
    belongs_to :origin, Account
    belongs_to :destination, Account

    timestamps()
  end

  def withdrawal_changeset(transaction, params) do
    transaction
    |> cast(params, [:origin_id, :value])
    |> cast_assoc(:origin)
    |> validate_required([:origin_id, :value])
  end

  def withdrawal(params, origin) do
    changeset = %Transaction{} |> Transaction.withdrawal_changeset(params)

    insert_transaction(changeset, origin.balance, params.value)
  end

  def transfer_changeset(transaction, params) do
    transaction
    |> cast(params, [:origin_id, :destination_id, :value])
    |> cast_assoc(:origin)
    |> cast_assoc(:destination)
    |> validate_required([:origin_id, :destination_id, :value])
  end

  def transfer(params, origin) do
    changeset = %Transaction{} |> Transaction.transfer_changeset(params)

    insert_transaction(changeset, origin.balance, params.value)
  end

  def insert_transaction(changeset, balance, value) do
    if valid_value(balance, value) do
      changeset
      |> Repo.insert()
    else
      {:error, Changeset.add_error(changeset, :value, "invalid value, should be less than value")}
    end
  end

  def valid_value(balance, value) do
    result = Decimal.cmp(Decimal.sub(balance, value), Decimal.new("0"))
    result == :eq || result == :gt
  end
end
