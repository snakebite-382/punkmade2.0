defmodule Punkmade.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Punkmade.Posts` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body",
        private: true,
        scene_id: 42,
        title: "some title",
        user_id: 42
      })
      |> Punkmade.Posts.create_post()

    post
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        content: "some content"
      })
      |> Punkmade.Posts.create_comment()

    comment
  end

  @doc """
  Generate a like.
  """
  def like_fixture(attrs \\ %{}) do
    {:ok, like} =
      attrs
      |> Enum.into(%{
        post_id: 42,
        user_id: 42
      })
      |> Punkmade.Posts.create_like()

    like
  end

  @doc """
  Generate a comment_like.
  """
  def comment_like_fixture(attrs \\ %{}) do
    {:ok, comment_like} =
      attrs
      |> Enum.into(%{
        comment_id: 42,
        user_id: 42
      })
      |> Punkmade.Posts.create_comment_like()

    comment_like
  end
end
