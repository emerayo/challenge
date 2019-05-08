defmodule Challenge.Transaction do
  @moduledoc """
  Schema responsible for handling an Account Transaction
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Challenge.Account
  alias Challenge.Repo
  alias Challenge.Transaction

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

  def withdrawal(params) do
    %Transaction{}
    |> Transaction.withdrawal_changeset(params)
    |> Repo.insert()
  end

  def transfer_changeset(transaction, params) do
    transaction
    |> cast(params, [:origin_id, :destination_id, :value])
  	|> cast_assoc(:origin)
  	|> cast_assoc(:destination)
    |> validate_required([:origin_id, :destination_id, :value])
  end

  def transfer(params) do
    %Transaction{}
    |> Transaction.transfer_changeset(params)
    |> Repo.insert()
  end
end
