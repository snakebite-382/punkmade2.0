defmodule Punkmade.Posts.Like do
  use Ecto.Schema
  import Ecto.Changeset

  schema "likes" do
    field :post_id, :integer
    field :user_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:post_id, :user_id])
    |> validate_required([:post_id, :user_id])
  end
end
