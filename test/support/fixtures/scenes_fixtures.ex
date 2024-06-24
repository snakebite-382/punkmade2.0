defmodule Punkmade.ScenesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Punkmade.Scenes` context.
  """

  @doc """
  Generate a scene.
  """
  def scene_fixture(attrs \\ %{}) do
    {:ok, scene} =
      attrs
      |> Enum.into(%{
        city: "some city",
        parent_scene_id: 42
      })
      |> Punkmade.Scenes.create_scene()

    scene
  end
end
