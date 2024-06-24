defmodule Punkmade.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :body, :text, null: false
      add :title, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :scene_id, references(:scenes, on_delete: :delete_all), null: false
      add :private, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
