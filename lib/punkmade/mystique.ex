defprotocol Punkmade.Mystique do
  def shape(entity, user, num_likes \\ %{num_likes: 0, user_liked: false})
end

defmodule Punkmade.MystiqueGenerics do
  def generic_format(
        entity,
        user,
        %{num_likes: num_likes, user_liked: user_liked}
      ) do
    %{
      id: entity.id,
      source: %{id: user.id, name: user.username, gravatar: user.gravatar_url},
      content: %{
        inserted_at: entity.inserted_at,
        likes_count: num_likes,
        user_liked: user_liked
      }
    }
  end
end

defimpl Punkmade.Mystique, for: Punkmade.Posts.Post do
  def shape(post, user, like_info) do
    Punkmade.MystiqueGenerics.generic_format(post, user, like_info)
    |> Map.update!(:content, fn content ->
      Map.put(content, :title, post.title)
      |> Map.put(:body, post.body)
    end)
  end
end

defimpl Punkmade.Mystique, for: Punkmade.Posts.Comment do
  def shape(comment, user, like_info) do
    Punkmade.MystiqueGenerics.generic_format(comment, user, like_info)
    |> Map.update!(:content, fn content ->
      Map.put(content, :body, comment.content)
    end)
  end
end
