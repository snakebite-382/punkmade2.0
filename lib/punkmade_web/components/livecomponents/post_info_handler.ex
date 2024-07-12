defmodule PunkmadeWeb.SharedPostHandlers do
  defmacro __using__(_opts) do
    quote do
      def handle_info(
            %Phoenix.Socket.Broadcast{
              event: "toggle_like",
              topic: "post:" <> scene_id,
              payload: %{id: post_id, liked: liked, user_id: user_id, origin: origin}
            },
            socket
          ) do
        if socket.assigns.scene_id == scene_id and
             origin != socket.id do
          send_update(PostComponent,
            id: post_id,
            liked: liked,
            user_id: user_id,
            current_user: socket.assigns.current_user
          )

          {:noreply, socket}
        else
          {:noreply, socket}
        end
      end
    end
  end
end
