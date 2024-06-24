defmodule Punkmade.Repo.Migrations.CreateScenes do
  use Ecto.Migration

  def change do
    create table(:scenes) do
      add :city, :string, null: false
      add :parent_scene_id, references(:scenes, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
  end
end
