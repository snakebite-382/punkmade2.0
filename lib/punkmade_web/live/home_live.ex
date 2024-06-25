defmodule PunkmadeWeb.HomeLive do
  use PunkmadeWeb, :live_view

  alias Punkmade.Scenes

  def mount(_params, _session, socket) do
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
end
