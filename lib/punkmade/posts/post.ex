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
  def creation_changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :title, :user_id, :scene_id, :private])
    |> validate_required([:body, :title, :user_id, :scene_id])
    |> validate_private()
    |> validate_body()
    |> validate_title()
  end

  defp validate_private(changeset) do
    private = get_change(changeset, :private)

    if private do
      changeset
    else
      changeset |> put_change(:private, false)
    end
  end

  defp validate_body(changeset) do
    changeset
    |> validate_length(:body, max: 2048, min: 16)
  end

  defp validate_title(changeset) do
    changeset
    |> validate_length(:title, max: 64, min: 4)
  end
end
