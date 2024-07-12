defmodule PostComponent do
  alias Punkmade.Dominatrix
  alias PunkmadeWeb.CoreComponents
  use Phoenix.LiveComponent
  alias Punkmade.Posts

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
    IO.puts("GOT THE LIKE UPDATE")

    post =
      socket.assigns.post
      |> set_like(liked, liked and user_id == user.id)

    {
      :ok,
      socket |> assign(%{id: post_id, current_user: user, post: post})
    }
  end

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  def handle_event("toggle_like", %{"post_id" => post_id}, socket) do
    user = socket.assigns.current_user

    liked = Posts.toggle_like?(post_id, user.id)

    post =
      socket.assigns.post
      |> set_like(liked, liked)

    {:noreply,
     Dominatrix.like(socket, "post", post.id, user.id, liked, socket.assigns.scene_id)
     |> assign(:post, post)}
  end

  defp set_like(post, liked, user_liked) do
    %{
      id: post.id,
      source: Map.get(post, :source),
      content:
        post
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
