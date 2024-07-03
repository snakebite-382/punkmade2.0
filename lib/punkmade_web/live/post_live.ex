defmodule PunkmadeWeb.PostLive do
  alias Punkmade.Posts
  use PunkmadeWeb, :live_view

  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(
       :post,
       Posts.get_post(
         String.to_integer(id),
         socket.assigns.current_user.id
       )
     )}
  end
end
