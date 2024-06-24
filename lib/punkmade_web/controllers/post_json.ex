defmodule PunkmadeWeb.PostJSON do
  alias Punkmade.Posts.Post

  @doc """
  Renders a list of posts.
  """
  def index(%{posts: posts}) do
    %{data: for(post <- posts, do: data(post))}
  end

  @doc """
  Renders a single post.
  """
  def show(%{post: post}) do
    %{data: data(post)}
  end

  defp data(%Post{} = post) do
    %{
      id: post.id,
      body: post.body,
      title: post.title,
      user_id: post.user_id,
      scene_id: post.scene_id,
      private: post.private
    }
  end
end
