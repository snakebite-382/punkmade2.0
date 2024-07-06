defmodule PunkmadeWeb.PostLive do
  alias Punkmade.Posts
  alias Punkmade.Posts.Comment
  use PunkmadeWeb, :live_view

  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Punkmade.PubSub, "comment:" <> id)
    end

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
     |> assign(
       :comments,
       []
     )}
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

  def handle_info(
        %{event: "new_comment", topic: "comment:" <> post_id, payload: comment},
        socket
      ) do
    IO.inspect(comment)

    if socket.assigns.post.id == String.to_integer(post_id) do
      {:noreply,
       socket
       |> update(:comments, fn comments ->
         comments ++ [comment]
       end)}
    else
      {:noreply, socket |> put_flash(:error, "ohuh")}
    end
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
