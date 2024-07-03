defmodule PunkmadeWeb.HomeLive do
  @post_batch_size 10

  use PunkmadeWeb, :live_view

  alias Punkmade.Scenes
  alias Punkmade.Posts
  alias Punkmade.Posts.Post

  def mount(_params, _session, socket) do
    if socket.assigns.current_user do
      socket =
        socket
        |> assign(:signed_in, "yes")
        |> assign(:memberships, Scenes.get_memberships(socket.assigns.current_user.id))
        |> assign(:posts, [])

      {:ok, socket}
    else
      socket =
        socket
        |> assign(:signed_in, "no")

      {:ok, socket}
    end
  end

  def handle_params(%{"scene_id" => scene_id}, _url, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Punkmade.PubSub, "post:#{scene_id}")
    end

    post_changeset =
      Posts.change_post(%Posts.Post{}, %{
        scene_id: scene_id,
        user_id: socket.assigns.current_user.id
      })

    {:noreply,
     socket
     |> assign(:post_form, to_form(post_changeset))
     |> assign(:scene_id, scene_id)
     |> get_posts(scene_id)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket |> assign(:post_form, nil)}
  end

  defp get_posts(socket, scene_id) do
    user = socket.assigns.current_user

    posts =
      if Map.get(socket.assigns, :last_time_fetched) do
        Posts.get_posts_by_scene(scene_id, @post_batch_size, socket.assigns.last_time_fetched)
      else
        Posts.get_posts_by_scene(scene_id, user.id, @post_batch_size)
      end

    if length(posts) == 0 do
      socket |> put_flash(:error, "no more posts to load, go outside or something")
    else
      %{content: %{inserted_at: last_time}} = List.last(posts)

      socket
      |> update(:posts, fn old_posts -> old_posts ++ posts end)
      |> assign(:last_time_fetched, last_time)
    end
  end

  def handle_event("navigate_scene", params, socket) do
    %{"scene" => scene_id} = params
    {:noreply, socket |> assign(:scene_id, scene_id) |> push_patch(to: "/?scene_id=#{scene_id}")}
  end

  def handle_event("validate_post", params, socket) do
    %{"post" => post_params} = params

    post_form =
      %Post{}
      |> Posts.change_post(post_params)
      |> Map.put(:action, :validate)
      |> to_form

    {:noreply, socket |> assign(:post_form, post_form)}
  end

  def handle_event("create_post", params, socket) do
    %{"post" => post_params} = params

    # keep user from setting scene_id and most importantly user_id themself while still allowing it to be used in validation changeset by setting it again here

    post_params
    |> Map.put("user_id", socket.assigns.current_user.id)
    |> Map.put("scene_id", socket.assigns.scene_id)
    |> Posts.create_post()
    |> case do
      {:ok, post} ->
        post_created(socket, post)

      {:error, changeset} ->
        error = "there was an error when creating your post"
        IO.inspect(changeset)

        {:noreply,
         socket
         |> put_flash(:error, error)
         |> assign(:post_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("load_more", _params, socket) do
    IO.puts("LAST TIME FETCHED")
    IO.inspect(socket.assigns.last_time_fetched)
    {:noreply, socket |> get_posts(socket.assigns.scene_id)}
  end

  def handle_event("toggle_like", %{"post_id" => post_id}, socket) do
    user = socket.assigns.current_user

    posts =
      socket.assigns.posts
      |> Enum.map(fn post ->
        if post.id == String.to_integer(post_id) do
          IO.inspect(post)

          %{
            id: post.id,
            source: Map.get(post, :source),
            content:
              post
              |> Map.get(:content)
              |> Map.put(:user_liked, Posts.toggle_like?(post.id, user.id))
          }
        else
          post
        end
      end)

    IO.inspect(posts)

    {:noreply, assign(socket, :posts, posts)}
  end

  def handle_info(
        %{event: "new_post", topic: "post:" <> scene_id, payload: post},
        socket
      ) do
    if socket.assigns.scene_id == scene_id do
      {:noreply, socket |> update(:posts, fn posts -> [post | posts] end)}
    else
      {:noreply, socket}
    end
  end

  defp post_created(socket, post) do
    info = "post created successfully"
    user = socket.assigns.current_user

    case PunkmadeWeb.Endpoint.broadcast(
           "post:#{socket.assigns.scene_id}",
           "new_post",
           Posts.format_post(post, user)
         ) do
      :ok ->
        {:noreply, socket |> put_flash(:info, info)}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           "Your post was created, but there was an error updating the feed for this scene, so a refresh might be required to see your post."
         )}
    end
  end
end
