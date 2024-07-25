defprotocol Punkmade.Postable do
  def shape(entity, user, likes)

  def fetch(entity, amount, user_id, parent_id, last_time_fetched)

  def post(entity, attrs, user_id, parent_id, socket)

  def like(entity, map, user_id, parent_id, socket)
end

defmodule Punkmade.Postable.Generics do
  import Ecto.Query
  alias Punkmade.Repo

  def format(
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

  def fetch(
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
        # on: field(l, ^like_key) == e.id and l.user_id == ^user_id,
        on: field(l, ^like_key) == e.id and l.user_id == ^user_id,
        left_join: lc in subquery(like_count_query),
        on: lc.entity_id == e.id,
        order_by: [desc: e.inserted_at],
        limit: ^batch_size,
        select: %{
          entity: e,
          user: u,
          user_liked: l,
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
      Punkmade.Postable.shape(result.entity, result.user, %{
        num_likes: result.likes_count,
        user_liked: result.user_liked
      })
    end)
  end

  def set_like(entity, liked, user_liked) do
    %{
      id: entity.id,
      source: Map.get(entity, :source),
      content:
        entity
        |> Map.get(:content)
        |> Map.put(:user_liked, user_liked)
        |> Map.update!(:likes_count, fn count ->
          if liked do
            count + 1
          else
            count - 1
          end
        end)
    }
  end
end

defimpl Punkmade.Postable, for: Punkmade.Posts.Post do
  alias Punkmade.Posts.Like
  alias Punkmade.Repo
  alias Punkmade.Posts
  alias Punkmade.Posts.Post
  alias Punkmade.Dominatrix
  alias Punkmade.Postable.Generics

  def shape(post, user, likes) do
    Generics.format(post, user, likes)
    |> Map.update!(:content, fn content ->
      Map.put(content, :title, post.title)
      |> Map.put(:body, post.body)
    end)
  end

  def fetch(_post, amount, user_id, scene_id, last_time_fetched \\ nil) do
    Punkmade.Postable.Generics.fetch(
      Punkmade.Posts.Post,
      scene_id,
      :scene_id,
      Like,
      :post_id,
      user_id,
      amount,
      last_time_fetched
    )
  end

  def post(post, attrs, user, scene_id, socket) do
    attrs =
      attrs
      |> Map.put("user_id", user.id)
      |> Map.put("scene_id", scene_id)

    post
    |> Post.creation_changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, post} ->
        Dominatrix.new(socket, "post", post, user, scene_id)

      {:error, changset} ->
        {:create_error, changset}
    end
  end

  def like(_entity, post, user_id, scene_id, socket) do
    liked = Posts.toggle_like?(post.id, user_id)

    post =
      post
      |> Generics.set_like(liked, liked)

    Dominatrix.like(socket, "post", post.id, user_id, liked, scene_id)

    post
  end
end

defimpl Punkmade.Postable, for: Punkmade.Posts.Comment do
  alias Punkmade.Posts.CommentLike
  alias Punkmade.Repo
  alias Punkmade.Posts
  alias Punkmade.Posts.Comment
  alias Punkmade.Dominatrix
  alias Punkmade.Postable.Generics

  def shape(comment, user, likes) do
    Generics.format(comment, user, likes)
    |> Map.update!(:content, fn content ->
      Map.put(content, :body, comment.content)
    end)
  end

  def fetch(_comment, amount, user_id, post_id, last_time_fetched \\ nil) do
    Punkmade.Postable.Generics.fetch(
      Punkmade.Posts.Comment,
      post_id,
      :post_id,
      CommentLike,
      :comment_id,
      user_id,
      amount,
      last_time_fetched
    )
  end

  def post(comment, attrs, user, post_id, socket) do
    attrs =
      attrs
      |> Map.put("user_id", user.id)
      |> Map.put("post_id", post_id)

    comment
    |> Comment.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, comment} ->
        Dominatrix.new(socket, "comment", comment, user, post_id)

      {:error, changset} ->
        {:create_error, changset}
    end
  end

  def like(_entity, comment, user_id, post_id, socket) do
    liked = Posts.toggle_like?(comment.id, user_id)

    comment =
      comment
      |> Generics.set_like(liked, liked)

    Dominatrix.like(socket, "comment", comment.id, user_id, liked, post_id)

    comment
  end
end

defmodule Punkmade.Postable.PubSubEndpoints do
  defmacro __using__(_opts) do
    quote do
      def handle_info(
            %{
              event: "toggle_like",
              topic: "post:" <> scene_id,
              payload: %{id: post_id, liked: liked, user_id: user_id, origin: origin}
            },
            socket
          ) do
        if socket.assigns.scene_id == scene_id and origin != socket.id do
          send_update(PostComponent,
            id: post_id,
            liked: liked,
            user_id: user_id,
            current_user: socket.assigns.current_user
          )
        end

        {:noreply, socket}
      end
    end
  end
end
