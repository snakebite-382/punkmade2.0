defmodule Punkmade.Repo.Migrations.AddUniquePlaceIdentifier do
  use Ecto.Migration

  def change do
    alter table(:scenes) do
      add :unique_place_identifier, :string, null: false
    end
  end
end
