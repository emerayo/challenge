defmodule Challenge.Account do
  @moduledoc """
  Schema responsible for handling Account's data
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Challenge.Account
  alias Challenge.Repo
  alias Ecto.Changeset

  schema "accounts" do
    field(:balance, :decimal, default: Decimal.new(1000))
    field(:email, :string)
    field(:encrypted_password, :string)
    field(:password, :string, virtual: true)

    timestamps()
  end

  def registration_changeset(account, params) do
    account
    |> cast(params, [:email, :encrypted_password])
    |> validate_required([:email, :encrypted_password])
    |> unique_constraint(:email, name: :unique_emails)
  end

  def sign_up(params) do
    %Account{}
    |> Account.registration_changeset(params)
    |> Repo.insert()
  end

  def changeset_error_to_string(changeset) do
    Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
