defmodule Punkmade.ScenesTest do
  use Punkmade.DataCase

  alias Punkmade.Scenes

  describe "scenes" do
    alias Punkmade.Scenes.Scene

    import Punkmade.ScenesFixtures

    @invalid_attrs %{city: nil, parent_scene_id: nil}

    test "list_scenes/0 returns all scenes" do
      scene = scene_fixture()
      assert Scenes.list_scenes() == [scene]
    end

    test "get_scene!/1 returns the scene with given id" do
      scene = scene_fixture()
      assert Scenes.get_scene!(scene.id) == scene
    end

    test "create_scene/1 with valid data creates a scene" do
      valid_attrs = %{city: "some city", parent_scene_id: 42}

      assert {:ok, %Scene{} = scene} = Scenes.create_scene(valid_attrs)
      assert scene.city == "some city"
      assert scene.parent_scene_id == 42
    end

    test "create_scene/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scenes.create_scene(@invalid_attrs)
    end

    test "update_scene/2 with valid data updates the scene" do
      scene = scene_fixture()
      update_attrs = %{city: "some updated city", parent_scene_id: 43}

      assert {:ok, %Scene{} = scene} = Scenes.update_scene(scene, update_attrs)
      assert scene.city == "some updated city"
      assert scene.parent_scene_id == 43
    end

    test "update_scene/2 with invalid data returns error changeset" do
      scene = scene_fixture()
      assert {:error, %Ecto.Changeset{}} = Scenes.update_scene(scene, @invalid_attrs)
      assert scene == Scenes.get_scene!(scene.id)
    end

    test "delete_scene/1 deletes the scene" do
      scene = scene_fixture()
      assert {:ok, %Scene{}} = Scenes.delete_scene(scene)
      assert_raise Ecto.NoResultsError, fn -> Scenes.get_scene!(scene.id) end
    end

    test "change_scene/1 returns a scene changeset" do
      scene = scene_fixture()
      assert %Ecto.Changeset{} = Scenes.change_scene(scene)
    end
  end
end
