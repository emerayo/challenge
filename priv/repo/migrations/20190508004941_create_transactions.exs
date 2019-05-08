defmodule Challenge.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :value, :decimal
      add :origin_id, references(:accounts)
      add :destination_id, references(:accounts)

      timestamps()
    end
  end
end
