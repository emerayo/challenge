defmodule Challenge.Transaction do
  @moduledoc """
  Schema responsible for handling an Account Transaction
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
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

    insert_transaction(changeset, origin, params.value)
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

    if params.destination_id == params.origin_id do
      {:error, Changeset.add_error(changeset, :destination, "invalid value, you can not transfer to yourself")}
    else
      insert_transaction(changeset, origin, params.value)
    end
  end

  def insert_transaction(changeset, origin, value) do
    if valid_value(origin.balance, value) do
      case (Repo.insert(changeset)) do
        {:ok, record}       ->
          Account.update_balance(origin, Decimal.sub(origin.balance, value))
          {:ok, record}
        {:error, changeset} -> {422, %{errors: Repo.changeset_error_to_string(changeset)}}
      end
    else
      {:error, Changeset.add_error(changeset, :value, "invalid value, should be less than balance $#{origin.balance}")}
    end
  end

  def valid_value(balance, value) do
    result = Decimal.cmp(Decimal.sub(balance, value), Decimal.new("0"))
    result == :eq || result == :gt
  end

  def sum_all_values do
    query = from(t in Transaction, select: sum(t.value))
    result = Repo.all(query)
    result = Enum.at(result, 0)

    if result == nil do
      Decimal.new("0")
    else
      result
    end
  end
end
