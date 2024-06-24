defmodule PunkmadeWeb.SceneControllerTest do
  use PunkmadeWeb.ConnCase

  import Punkmade.ScenesFixtures

  alias Punkmade.Scenes.Scene

  @create_attrs %{
    city: "some city",
    parent_scene_id: 42
  }
  @update_attrs %{
    city: "some updated city",
    parent_scene_id: 43
  }
  @invalid_attrs %{city: nil, parent_scene_id: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all scenes", %{conn: conn} do
      conn = get(conn, ~p"/api/scenes")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create scene" do
    test "renders scene when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/scenes", scene: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/scenes/#{id}")

      assert %{
               "id" => ^id,
               "city" => "some city",
               "parent_scene_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/scenes", scene: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update scene" do
    setup [:create_scene]

    test "renders scene when data is valid", %{conn: conn, scene: %Scene{id: id} = scene} do
      conn = put(conn, ~p"/api/scenes/#{scene}", scene: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/scenes/#{id}")

      assert %{
               "id" => ^id,
               "city" => "some updated city",
               "parent_scene_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, scene: scene} do
      conn = put(conn, ~p"/api/scenes/#{scene}", scene: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete scene" do
    setup [:create_scene]

    test "deletes chosen scene", %{conn: conn, scene: scene} do
      conn = delete(conn, ~p"/api/scenes/#{scene}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/scenes/#{scene}")
      end
    end
  end

  defp create_scene(_) do
    scene = scene_fixture()
    %{scene: scene}
  end
end
