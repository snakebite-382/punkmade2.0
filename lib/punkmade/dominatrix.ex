defmodule Punkmade.Dominatrix do
  alias Punkmade.Mystique

  def subscribe(channel, parent_id, socket) do
    if Phoenix.LiveView.connected?(socket) do
      case Phoenix.PubSub.subscribe(Punkmade.PubSub, "#{channel}:#{parent_id}") do
        :ok ->
          :ok

        {:error, stuff} ->
          IO.inspect(stuff)
          :error
      end
    end
  end

  def new(channel, object, user, parent_id) do
    info = "#{channel} created successfully"
    error = "your #{channel} was created but there was an error updating the feed"

    case PunkmadeWeb.Endpoint.broadcast(
           "#{channel}:#{parent_id}",
           "new_#{channel}",
           Mystique.shape(object, user)
         ) do
      :ok ->
        {:ok, info}

      {:error, _} ->
        {:error, error}
    end
  end

  def like(socket, channel, object_id, user_id, liked, parent_id) do
    case PunkmadeWeb.Endpoint.broadcast(
           "#{channel}:#{parent_id}",
           "toggle_like",
           %{id: object_id, liked: liked, user_id: user_id, origin: socket.id}
         ) do
      :ok ->
        socket

      {:error, _} ->
        Phoenix.LiveView.put_flash(
          socket,
          :error,
          "your like was created, but there was an error updating the feed"
        )
    end
  end
end
