defmodule PunkmadeWeb.PageController do
  use PunkmadeWeb, :controller

  def home(conn, _params) do
    conn
    |> render(:home)
  end
end
