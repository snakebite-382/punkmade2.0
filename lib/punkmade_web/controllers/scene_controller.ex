defmodule PunkmadeWeb.SceneController do
  use PunkmadeWeb, :controller

  alias Punkmade.Scenes
  alias Punkmade.Scenes.Scene

  action_fallback PunkmadeWeb.FallbackController

  def index(conn, _params) do
    scenes = Scenes.list_scenes()
    render(conn, :index, scenes: scenes)
  end

  def create(conn, %{"scene" => scene_params}) do
    with {:ok, %Scene{} = scene} <- Scenes.create_scene(scene_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/scenes/#{scene}")
      |> render(:show, scene: scene)
    end
  end

  def show(conn, %{"id" => id}) do
    scene = Scenes.get_scene!(id)
    render(conn, :show, scene: scene)
  end

  def update(conn, %{"id" => id, "scene" => scene_params}) do
    scene = Scenes.get_scene!(id)

    with {:ok, %Scene{} = scene} <- Scenes.update_scene(scene, scene_params) do
      render(conn, :show, scene: scene)
    end
  end

  def delete(conn, %{"id" => id}) do
    scene = Scenes.get_scene!(id)

    with {:ok, %Scene{}} <- Scenes.delete_scene(scene) do
      send_resp(conn, :no_content, "")
    end
  end
end
