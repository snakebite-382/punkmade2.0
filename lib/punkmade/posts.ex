defmodule Punkmade.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Punkmade.Repo

  alias Punkmade.Posts.Post

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.
  """
  def get_post!(id), do: Repo.get!(Post, id)

  def get_posts_by_scene(scene_id, batch_size, last_time_fetched \\ nil) do
    base_query =
      from(p in Post,
        join: u in Punkmade.Accounts.User,
        on: u.id == p.user_id,
        order_by: [desc: p.inserted_at],
        limit: ^batch_size,
        select: %{source: %{id: u.id, name: u.username}, content: p}
      )

    query =
      if last_time_fetched do
        from(p in base_query,
          where: p.scene_id == ^scene_id and p.inserted_at < ^last_time_fetched
        )
      else
        from(p in base_query,
          where: p.scene_id == ^scene_id
        )
      end

    Repo.all(query)
  end

  @doc """
  Creates a post.
  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.creation_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a post.
  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.
  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.creation_changeset(post, attrs)
  end
end
