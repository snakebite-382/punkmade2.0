defmodule Punkmade.Dominatrix do
  alias Punkmade.Postable

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

  def new(socket, channel, object, user, parent_id) do
    info = "#{channel} created successfully"
    error = "your #{channel} was created but there was an error updating the feed"
    object = Postable.shape(object, user, %{num_likes: 0, user_liked: false})

    case PunkmadeWeb.Endpoint.broadcast(
           "#{channel}:#{parent_id}",
           "new_#{channel}",
           %{
             object: object,
             origin: socket.id
           }
         ) do
      :ok ->
        {:ok, %{msg: info, created: object}}

      {:error, err} ->
        IO.inspect("error", err)
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
