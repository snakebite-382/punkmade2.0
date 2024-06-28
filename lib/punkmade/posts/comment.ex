defmodule Punkmade.Posts.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :content, :string
    field :post_id, :integer
    field :user_id, :integer
    field :parent_comment, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:post_id, :user_id, :parent_comment, :content])
    |> validate_required([:post_id, :user_id, :content])
    |> validate_content()
  end

  defp validate_content(changeset) do
    changeset
    |> validate_length(:content, min: 10, max: 255)
  end
end
