defprotocol Punkmade.Fido do
  @doc """
  Fetch `batchsize` entities with a parent of `foreign_id` posted after `last_time_fetched`
  """
  def fetch_many(entity, user_id, foreign_id, batch_size, last_time_fetched \\ nil)
end

defimpl Punkmade.Fido, for: Punkmade.Posts.Post do
  alias Punkmade.Posts.Like

  def fetch_many(_entity, user_id, scene_id, batch_size, last_time_fetched \\ nil) do
    Punkmade.FidoGenerics.generic_fetch_many(
      Punkmade.Posts.Post,
      scene_id,
      :scene_id,
      Like,
      :post_id,
      user_id,
      batch_size,
      last_time_fetched
    )
  end
end

defimpl Punkmade.Fido, for: Punkmade.Posts.Comment do
  def fetch_many(_entity, user_id, post_id, batch_size, last_time_fetched \\ nil) do
    Punkmade.FidoGenerics.generic_fetch_many(
      Punkmade.Posts.Comment,
      post_id,
      :post_id,
      Punkmade.Posts.CommentLike,
      :comment_id,
      user_id,
      batch_size,
      last_time_fetched
    )
    |> Enum.reverse()
  end
end

import Ecto.Query
alias Punkmade.Repo

defmodule Punkmade.FidoGenerics do
  alias Punkmade.Mystique

  def generic_fetch_many(
        module,
        parent_id,
        parent_key,
        like_module,
        like_key,
        user_id,
        batch_size,
        last_time_fetched \\ nil
      ) do
    like_count_query =
      from l in like_module,
        group_by: field(l, ^like_key),
        select: %{likes_count: count(l.id), entity_id: field(l, ^like_key)}

    base_query =
      from(e in module,
        join: u in Punkmade.Accounts.User,
        on: u.id == e.user_id,
        left_join: l in ^like_module,
        on: field(l, ^like_key) == e.id and l.user_id == ^user_id,
        left_join: lc in subquery(like_count_query),
        on: lc.entity_id == e.id,
        order_by: [desc: e.inserted_at],
        limit: ^batch_size,
        select: %{
          entity: e,
          user: u,
          user_liked: not is_nil(l.id),
          likes_count: coalesce(lc.likes_count, 0)
        }
      )

    query =
      if last_time_fetched do
        from(e in base_query,
          where: field(e, ^parent_key) == ^parent_id and e.inserted_at < ^last_time_fetched
        )
      else
        from(e in base_query,
          where: field(e, ^parent_key) == ^parent_id
        )
      end

    Enum.map(Repo.all(query), fn result ->
      Mystique.shape(result.entity, result.user, %{
        num_likes: result.likes_count,
        user_liked: result.user_liked
      })
    end)
  end
end
