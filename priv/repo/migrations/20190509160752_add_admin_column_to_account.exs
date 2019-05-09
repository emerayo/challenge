defmodule Challenge.Repo.Migrations.AddAdminColumnToAccount do
  use Ecto.Migration

  def change do
    alter table("accounts") do
      add :admin, :boolean, default: false
    end
  end
end
