defmodule Punkmade.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships) do
      add :user_id, :integer
      add :scene_id, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
