defmodule PunkmadeWeb.PageController do
  use PunkmadeWeb, :controller

  def home(conn, _params) do
    conn
    |> put_flash(:error, "test")
    |> render(:home)
  end
end
