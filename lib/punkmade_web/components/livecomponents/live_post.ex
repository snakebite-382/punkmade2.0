defmodule PostComponent do
  alias Punkmade.Postable
  alias PunkmadeWeb.CoreComponents
  alias Punkmade.Posts.Post
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div class="my-4 flex-col flex cursor-pointer">
      <.link navigate={"/post?id=#{@post.id}&scene_id=#{@scene_id}"}>
        <div><%= @post.source.name %> :</div>
        <div><%= @post.content.title %></div>
        <div><%= @post.content.body %></div>
      </.link>
      <div>
        <%= @post.content.likes_count %>
        <CoreComponents.icon
          class={
            if @post.content.user_liked do
              "bg-accent"
            else
              "bg-fg"
            end
          }
          name={
            if @post.content.user_liked do
              "hero-heart-solid"
            else
              "hero-heart"
            end
          }
          phx-click="toggle_like"
          phx-value-post_id={@post.id}
          phx-target={@myself}
        />
      </div>
    </div>
    """
  end

  def update(%{id: post_id, liked: liked, user_id: user_id, current_user: user}, socket) do
    post =
      socket.assigns.post
      |> Postable.Generics.set_like(liked, liked and user_id == user.id)

    {
      :ok,
      socket |> assign(%{id: post_id, current_user: user, post: post})
    }
  end

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  def handle_event("toggle_like", %{"post_id" => _post_id}, socket) do
    user = socket.assigns.current_user
    post = socket.assigns.post
    scene_id = socket.assigns.scene_id

    {:noreply, socket |> assign(post: Postable.like(%Post{}, post, user.id, scene_id, socket))}
  end
end
