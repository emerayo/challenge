defmodule Challenge.Account do
  use Ecto.Schema
  import Ecto.Changeset
  alias Challenge.{Account, Repo}

  schema "accounts" do
    field(:email, :string)
    field(:encrypted_password, :string)
    field(:password, :string, virtual: true)

    timestamps()
  end

  def changeset(account, params \\ :empty) do
    account
    |> cast(params, [:email, :encrypted_password])
    |> validate_required([:email, :encrypted_password])
  end
end
