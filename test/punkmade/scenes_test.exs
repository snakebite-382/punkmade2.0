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

  describe "memberships" do
    alias Punkmade.Scenes.Membership

    import Punkmade.ScenesFixtures

    @invalid_attrs %{scene_id: nil, user_id: nil}

    test "list_memberships/0 returns all memberships" do
      membership = membership_fixture()
      assert Scenes.list_memberships() == [membership]
    end

    test "get_membership!/1 returns the membership with given id" do
      membership = membership_fixture()
      assert Scenes.get_membership!(membership.id) == membership
    end

    test "create_membership/1 with valid data creates a membership" do
      valid_attrs = %{scene_id: 42, user_id: 42}

      assert {:ok, %Membership{} = membership} = Scenes.create_membership(valid_attrs)
      assert membership.scene_id == 42
      assert membership.user_id == 42
    end

    test "create_membership/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scenes.create_membership(@invalid_attrs)
    end

    test "update_membership/2 with valid data updates the membership" do
      membership = membership_fixture()
      update_attrs = %{scene_id: 43, user_id: 43}

      assert {:ok, %Membership{} = membership} = Scenes.update_membership(membership, update_attrs)
      assert membership.scene_id == 43
      assert membership.user_id == 43
    end

    test "update_membership/2 with invalid data returns error changeset" do
      membership = membership_fixture()
      assert {:error, %Ecto.Changeset{}} = Scenes.update_membership(membership, @invalid_attrs)
      assert membership == Scenes.get_membership!(membership.id)
    end

    test "delete_membership/1 deletes the membership" do
      membership = membership_fixture()
      assert {:ok, %Membership{}} = Scenes.delete_membership(membership)
      assert_raise Ecto.NoResultsError, fn -> Scenes.get_membership!(membership.id) end
    end

    test "change_membership/1 returns a membership changeset" do
      membership = membership_fixture()
      assert %Ecto.Changeset{} = Scenes.change_membership(membership)
    end
  end
end
