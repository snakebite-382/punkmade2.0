defmodule Punkmade.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :content, :string, null: false
      add :post_id, references(:posts, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :parent_comment, references(:comments, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
