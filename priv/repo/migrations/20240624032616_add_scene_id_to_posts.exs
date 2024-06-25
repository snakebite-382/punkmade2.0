defmodule Punkmade.Repo.Migrations.AddSceneIdToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :scene_id, references(:scenes, on_delete: :delete_all), null: false
    end
  end
end
