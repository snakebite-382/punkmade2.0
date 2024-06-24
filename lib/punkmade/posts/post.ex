defmodule Punkmade.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :private, :boolean, default: false
    field :scene_id, :integer
    field :title, :string
    field :user_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :title, :user_id, :scene_id, :private])
    |> validate_required([:body, :title, :user_id, :scene_id, :private])
  end
end
