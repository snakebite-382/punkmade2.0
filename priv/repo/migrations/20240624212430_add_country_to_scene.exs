defmodule Punkmade.Repo.Migrations.AddCountryToScene do
  use Ecto.Migration

  def change do
    alter table(:scenes) do
      add :country, :string, null: false
    end
  end
end
