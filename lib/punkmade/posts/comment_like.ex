defmodule Punkmade.Posts.CommentLike do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comment_likes" do
    field :comment_id, :integer
    field :user_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment_like, attrs) do
    comment_like
    |> cast(attrs, [:comment_id, :user_id])
    |> validate_required([:comment_id, :user_id])
  end
end
