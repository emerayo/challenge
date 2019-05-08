defmodule Challenge.Account do
  @moduledoc """
  Schema responsible for handling Account's data
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Challenge.Account
  alias Challenge.Repo
  alias Challenge.Transaction
  alias Ecto.Changeset

  schema "accounts" do
    field(:balance, :decimal, default: Decimal.new(1000))
    field(:email, :string)
    field(:encrypted_password, :string)
    field(:password, :string, virtual: true)
    has_many :transactions, Transaction

    timestamps()
  end

  def changeset(account, params) do
    account
    |> cast(params, [:email, :encrypted_password])
    |> validate_required([:email, :encrypted_password])
    |> unique_constraint(:email, name: :unique_emails)
  end

  def sign_up(params) do
    %Account{}
    |> Account.changeset(params)
    |> Repo.insert()
  end
end
