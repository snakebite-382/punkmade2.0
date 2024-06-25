defmodule Punkmade.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Punkmade.Repo

  alias Punkmade.Posts.Post

  @doc """
  Returns the list of posts.
  """
  def list_posts do
    Repo.all(Post)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.
  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.
  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.creation_changeset(attrs)
    |> Repo.insert()
  end

  # @doc """
  # Updates a post.

  # ## Examples

  #     iex> update_post(post, %{field: new_value})
  #     {:ok, %Post{}}

  #     iex> update_post(post, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_post(%Post{} = post, attrs) do
  #   post
  #   |> Post.changeset(attrs)
  #   |> Repo.update()
  # end

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
