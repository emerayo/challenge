defmodule Challenge.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add(:encrypted_password, :string, null: false)
      add(:email, :string)

      timestamps
    end

    create(unique_index(:accounts, [:email], name: :unique_emails))
  end
end
