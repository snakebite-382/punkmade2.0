defmodule PunkmadeWeb.SceneJSON do
  alias Punkmade.Scenes.Scene

  @doc """
  Renders a list of scenes.
  """
  def index(%{scenes: scenes}) do
    %{data: for(scene <- scenes, do: data(scene))}
  end

  @doc """
  Renders a single scene.
  """
  def show(%{scene: scene}) do
    %{data: data(scene)}
  end

  defp data(%Scene{} = scene) do
    %{
      id: scene.id,
      city: scene.city,
      parent_scene_id: scene.parent_scene_id
    }
  end
end
