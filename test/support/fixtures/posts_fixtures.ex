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
end
