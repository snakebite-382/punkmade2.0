defmodule PunkmadeWeb.PostLive do
  @comment_batch_size 5
  alias Punkmade.Dominatrix
  alias Punkmade.Posts
  alias Punkmade.Posts.Comment
  use PunkmadeWeb, :live_view
  use Punkmade.Postable.PubSubEndpoints

  def mount(%{"id" => id, "scene_id" => scene_id}, _session, socket) do
    Dominatrix.subscribe("comment", id, socket)
    Dominatrix.subscribe("post", scene_id, socket)

    {:ok,
     socket
     |> assign(
       :post,
       Posts.get_post(
         String.to_integer(id),
         socket.assigns.current_user.id
       )
     )
     |> assign(
       :comment_form,
       to_form(
         Posts.change_comment(
           %Comment{},
           %{}
         )
       )
     )
     |> assign(:comments, [])
     |> assign(:scene_id, scene_id)
     |> fetch_comments(id)}
  end

  defp fetch_comments(socket, post_id) do
    user = socket.assigns.current_user

    comments =
      if Map.get(socket.assigns, :last_time_fetched) do
        Posts.get_comments(
          post_id,
          user.id,
          @comment_batch_size,
          socket.assigns.last_time_fetched
        )
      else
        Posts.get_comments(post_id, user.id, @comment_batch_size)
      end

    if length(comments) == 0 do
      socket |> put_flash(:error, "no more comments to fetch, go outside or something")
    else
      %{content: %{inserted_at: last_time}} = List.first(comments)

      socket
      |> update(:comments, fn old_comments -> comments ++ old_comments end)
      |> assign(:last_time_fetched, last_time)
    end
  end

  def handle_event("load_comments", _params, socket) do
    {:noreply,
     socket
     |> fetch_comments(socket.assigns.post.id)}
  end

  def handle_event("validate_comment", %{"comment" => comment_params}, socket) do
    comment_form =
      %Comment{}
      |> Posts.change_comment(comment_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, socket |> assign(:comment_form, comment_form)}
  end

  def handle_event("create_comment", %{"comment" => comment_params}, socket) do
    comment_params
    |> Map.put("user_id", socket.assigns.current_user.id)
    |> Map.put("post_id", socket.assigns.post.id)
    |> Posts.create_comment()
    |> case do
      {:ok, comment} ->
        comment_created(socket, comment)

      {:error, changeset} ->
        error = "There was an error posting your comment"

        comment_form =
          changeset
          |> Map.put(:action, :insert)
          |> to_form()

        {:noreply,
         socket
         |> put_flash(:error, error)
         |> assign(:comment_form, comment_form)}
    end
  end

  def handle_event("toggle_comment_like", %{"comment_id" => comment_id}, socket) do
    user = socket.assigns.current_user

    liked = Posts.toggle_comment_like?(comment_id, user.id)

    comments =
      socket.assigns.comments
      |> Enum.map(fn comment ->
        if comment.id == String.to_integer(comment_id) do
          %{
            id: comment.id,
            source: Map.get(comment, :source),
            content:
              comment
              |> Map.get(:content)
              |> Map.put(:user_liked, liked)
              |> Map.update!(:likes_count, fn count ->
                if liked do
                  count + 1
                else
                  count - 1
                end
              end)
          }
        else
          comment
        end
      end)

    {:noreply,
     assign(socket, :comments, comments)
     |> Dominatrix.like("comment", comment_id, user.id, liked, socket.assigns.post.id)}
  end

  def handle_info(
        %{event: "new_comment", topic: "comment:" <> post_id, payload: comment},
        socket
      ) do
    if socket.assigns.post.id == String.to_integer(post_id) do
      {:noreply,
       socket
       |> update(:comments, fn comments ->
         comments ++ comment
       end)}
    else
      {:noreply, socket |> put_flash(:error, "ohuh")}
    end
  end

  def handle_info(
        %{
          event: "toggle_like",
          topic: "comment:" <> post_id,
          payload: %{
            id: id,
            liked: liked,
            user_id: user_id,
            origin: origin
          }
        },
        socket
      ) do
    if socket.assigns.post.id == String.to_integer(post_id) and origin != socket.id do
      comment =
        Enum.find(socket.assigns.comments, fn comment ->
          comment.id == String.to_integer(id)
        end)
        |> set_like(liked, user_id == socket.assigns.current_user.id and liked)

      comments = set_comment(comment, socket.assigns.comments)

      {:noreply, update(socket, :comments, fn _ -> comments end)}
    else
      IO.puts("IGNORING")
      {:noreply, socket}
    end
  end

  defp set_comment(comment, comments) do
    Enum.map(comments, fn entry ->
      if entry.id == comment.id do
        comment
      else
        entry
      end
    end)
  end

  defp set_like(comment, liked, user_liked) do
    %{
      id: comment.id,
      source: Map.get(comment, :source),
      content:
        comment
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

  defp comment_created(socket, comment) do
    info = "Commented"

    case PunkmadeWeb.Endpoint.broadcast(
           "comment:#{socket.assigns.post.id}",
           "new_comment",
           Posts.format_comment(comment, socket.assigns.current_user)
         ) do
      :ok ->
        IO.puts("sent")
        {:noreply, socket |> put_flash(:info, info)}

      {:error, _} ->
        error =
          "Your comment was created, but there was an error updating the feed, a refresh may be required"

        {:noreply, socket |> put_flash(:error, error)}
    end

    {:noreply, socket |> put_flash(:info, info)}
  end
end
