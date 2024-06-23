defmodule Punkmade.Repo.Migrations.GravatarToBinary do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :gravatar_url, :binary
    end
  end
end
