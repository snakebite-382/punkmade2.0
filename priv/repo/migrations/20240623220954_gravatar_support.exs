defmodule Punkmade.Repo.Migrations.GravatarSupport do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :gravatar_url, :text
    end
  end
end
