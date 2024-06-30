defmodule PunkmadeWeb.PostLive do
  use PunkmadeWeb, :live_view

  def mount(params, _session, socket) do
    IO.inspect(params)
    {:ok, socket}
  end
end
