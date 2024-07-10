defmodule Punkmade.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Punkmade.Posts.Like
  alias Punkmade.Repo
  alias Punkmade.Accounts.User
  alias Punkmade.Posts.Post
  alias Punkmade.Posts.CommentLike

  @doc """
  takes in a post and the user who posted it and formats everything into a single map as expected by pages displaying a post
  """
  def format_post(%Post{} = post, %User{} = user, num_likes \\ 0, user_liked \\ false) do
    %{
      id: post.id,
      source: %{id: user.id, name: user.username},
      content: %{
        title: post.title,
        body: post.body,
        inserted_at: post.inserted_at,
        likes_count: num_likes,
        user_liked: user_liked
      }
    }
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.
  """
  def get_post(id, user_id) do
    like_count_query =
      from l in Like,
        group_by: l.post_id,
        select: %{likes_count: count(l.id), post_id: l.post_id}

    query =
      from p in Post,
        where: p.id == ^id,
        join: u in Punkmade.Accounts.User,
        on: u.id == p.user_id,
        left_join: l in Like,
        on: l.post_id == p.id and l.user_id == ^user_id,
        left_join: lc in subquery(like_count_query),
        on: lc.post_id == p.id,
        select: %{
          post: p,
          user: u,
          user_liked: not is_nil(l.id),
          likes_count: coalesce(lc.likes_count, 0)
        }

    result = Repo.one(query)
    format_post(result.post, result.user, result.likes_count, result.user_liked)
  end

  def get_posts_by_scene(scene_id, user_id, batch_size, last_time_fetched \\ nil) do
    Punkmade.Fido.fetch_many(
      %Punkmade.Posts.Post{},
      user_id,
      scene_id,
      batch_size,
      last_time_fetched
    )
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

  alias Punkmade.Posts.Comment

  def get_comments(post_id, user_id, batch_size, last_time_fetched \\ nil) do
    Punkmade.Fido.fetch_many(
      %Punkmade.Posts.Comment{},
      user_id,
      post_id,
      batch_size,
      last_time_fetched
    )
  end

  @doc """
  Creates a comment.
  """
  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.
  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.
  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.
  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end

  @doc """
  Formats a comment
  """
  def format_comment(%Comment{} = comment, %User{} = user, num_likes \\ 0, user_liked \\ false) do
    %{
      id: comment.id,
      source: %{id: user.id, name: user.username},
      content: %{
        body: comment.content,
        inserted_at: comment.inserted_at,
        likes_count: num_likes,
        user_liked: user_liked
      }
    }
  end

  alias Punkmade.Posts.Like

  @doc """
  Gets a single like.

  Raises `Ecto.NoResultsError` if the Like does not exist.
  """
  def get_like!(id), do: Repo.get!(Like, id)

  @doc """
  Creates a like.
  """
  def create_like(attrs \\ %{}) do
    %Like{}
    |> Like.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a like.
  """
  def delete_like(%Like{} = like) do
    Repo.delete(like)
  end

  def toggle_like?(post_id, user_id) do
    like_exist_query =
      from l in Like,
        where: l.post_id == ^post_id and l.user_id == ^user_id,
        limit: 1

    case Repo.one(like_exist_query) do
      nil ->
        create_like(%{user_id: user_id, post_id: post_id})
        true

      like ->
        delete_like(like)
        false
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking like changes.
  """
  def change_like(%Like{} = like, attrs \\ %{}) do
    Like.changeset(like, attrs)
  end

  def toggle_comment_like?(comment_id, user_id) do
    like_exist_query =
      from l in CommentLike,
        where: l.comment_id == ^comment_id and l.user_id == ^user_id,
        limit: 1

    case Repo.one(like_exist_query) do
      nil ->
        create_comment_like(%{user_id: user_id, comment_id: comment_id})
        true

      like ->
        delete_comment_like(like)
        false
    end
  end

  def create_comment_like(attrs \\ %{}) do
    %CommentLike{}
    |> CommentLike.changeset(attrs)
    |> Repo.insert()
  end

  def delete_comment_like(%CommentLike{} = like) do
    Repo.delete(like)
  end
end
