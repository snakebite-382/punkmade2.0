defmodule Punkmade.Scenes.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  schema "memberships" do
    field :scene_id, :integer
    field :user_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:user_id, :scene_id])
    |> validate_required([:user_id, :scene_id])
  end
end
