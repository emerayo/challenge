defmodule Challenge.Repo.Migrations.AddBalanceToAccounts do
  use Ecto.Migration

  def change do
  	alter table("accounts") do
	  add :balance, :decimal, default: 1000.0
	end
  end
end
