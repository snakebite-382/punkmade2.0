defmodule Punkmade.Scenes.Scene do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scenes" do
    field :city, :string
    field :parent_scene_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scene, attrs) do
    scene
    |> cast(attrs, [:city, :parent_scene_id])
    |> validate_required([:city, :parent_scene_id])
  end
end
