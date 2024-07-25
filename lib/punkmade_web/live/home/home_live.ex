defmodule PunkmadeWeb.HomeLive do
  @post_batch_size 10

  use PunkmadeWeb, :live_view
  use Punkmade.Postable.PubSubEndpoints

  alias Punkmade.Scenes
  alias Punkmade.Posts
  alias Punkmade.Posts.Post
  alias Punkmade.Dominatrix
  alias Punkmade.Postable

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
    Dominatrix.subscribe("post", scene_id, socket)

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
        Posts.get_posts_by_scene(
          scene_id,
          user.id,
          @post_batch_size,
          socket.assigns.last_time_fetched
        )
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
    %{scene_id: scene_id, current_user: user} = socket.assigns

    Postable.post(%Post{}, post_params, user, scene_id, socket)
    |> case do
      {:ok, %{msg: msg, created: post}} ->
        {:noreply,
         socket |> put_flash(:info, msg) |> update(:posts, fn posts -> [post | posts] end)}

      {:error, error} ->
        {:noreply, socket.put_flash(:error, error)}

      {:create_error, changeset} ->
        error = "there was an error creating your post"

        {:noreply,
         socket
         |> put_flash(:error, error)
         |> assign(:post_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("load_more", _params, socket) do
    {:noreply, socket |> get_posts(socket.assigns.scene_id)}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "new_post",
          topic: "post:" <> scene_id,
          payload: %{object: post, origin: origin}
        },
        socket
      ) do
    if socket.assigns.scene_id == scene_id and origin != socket.id do
      {:noreply, socket |> update(:posts, fn posts -> [post | posts] end)}
    else
      {:noreply, socket}
    end
  end
end
