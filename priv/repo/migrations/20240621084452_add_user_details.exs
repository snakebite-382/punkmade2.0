defmodule Punkmade.Repo.Migrations.AddUserDetails do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :string, null: false, size: 32
      add :full_name, :string, null: false, size: 255
      add :bio, :string, size: 255
      add :pronouns, :string, size: 20
      add :gravatar_url, :string
    end

    create unique_index(:users, [:username])
  end
end
