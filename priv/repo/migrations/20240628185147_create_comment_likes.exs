defmodule Punkmade.Repo.Migrations.CreateCommentLikes do
  use Ecto.Migration

  def change do
    create table(:comment_likes) do
      add :comment_id, references(:comments, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
