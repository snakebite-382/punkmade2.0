defmodule Punkmade.Repo.Migrations.AddStatesToScene do
  use Ecto.Migration

  def change do
    alter table(:scenes) do
      add :state, :string
    end
  end
end
