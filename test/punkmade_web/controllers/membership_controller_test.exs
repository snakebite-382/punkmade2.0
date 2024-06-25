defmodule PunkmadeWeb.MembershipControllerTest do
  use PunkmadeWeb.ConnCase

  import Punkmade.ScenesFixtures

  alias Punkmade.Scenes.Membership

  @create_attrs %{
    scene_id: 42,
    user_id: 42
  }
  @update_attrs %{
    scene_id: 43,
    user_id: 43
  }
  @invalid_attrs %{scene_id: nil, user_id: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all memberships", %{conn: conn} do
      conn = get(conn, ~p"/api/memberships")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create membership" do
    test "renders membership when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/memberships", membership: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/memberships/#{id}")

      assert %{
               "id" => ^id,
               "scene_id" => 42,
               "user_id" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/memberships", membership: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update membership" do
    setup [:create_membership]

    test "renders membership when data is valid", %{conn: conn, membership: %Membership{id: id} = membership} do
      conn = put(conn, ~p"/api/memberships/#{membership}", membership: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/memberships/#{id}")

      assert %{
               "id" => ^id,
               "scene_id" => 43,
               "user_id" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, membership: membership} do
      conn = put(conn, ~p"/api/memberships/#{membership}", membership: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete membership" do
    setup [:create_membership]

    test "deletes chosen membership", %{conn: conn, membership: membership} do
      conn = delete(conn, ~p"/api/memberships/#{membership}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/memberships/#{membership}")
      end
    end
  end

  defp create_membership(_) do
    membership = membership_fixture()
    %{membership: membership}
  end
end
