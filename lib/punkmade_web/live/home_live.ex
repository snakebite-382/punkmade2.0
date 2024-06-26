defmodule PunkmadeWeb.HomeLive do
  use PunkmadeWeb, :live_view

  alias Punkmade.Scenes
  alias Punkmade.Posts
  alias Punkmade.Posts.Post

  def mount(_params, _session, socket) do
    IO.puts("MOUNT")

    if socket.assigns.current_user do
      socket =
        socket
        |> assign(:signed_in, "yes")
        |> assign(:memberships, Scenes.get_memberships(socket.assigns.current_user.id))

      {:ok, socket}
    else
      socket =
        socket
        |> assign(:signed_in, "no")

      {:ok, socket}
    end
  end

  def handle_params(%{"scene_id" => scene_id}, _url, socket) do
    post_changeset =
      Posts.change_post(%Posts.Post{}, %{
        scene_id: scene_id,
        user_id: socket.assigns.current_user.id
      })

    {:noreply,
     socket
     |> assign(:post_form, to_form(post_changeset))
     |> assign(:scene_id, scene_id)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket |> assign(:post_form, nil)}
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
      {:ok, _post} ->
        info = "post created successfully"

        {:noreply, socket |> put_flash(:info, info)}

      {:error, changeset} ->
        error = "there was an error when creating your post"
        IO.inspect(changeset)

        {:noreply,
         socket
         |> put_flash(:error, error)
         |> assign(:post_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end
end
