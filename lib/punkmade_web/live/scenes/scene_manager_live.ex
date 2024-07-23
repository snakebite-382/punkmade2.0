defmodule PunkmadeWeb.SceneManagerLive do
  use PunkmadeWeb, :live_view
  alias Punkmade.Scenes
  alias Punkmade.Scenes.Scene

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    scene_changeset = Scenes.change_scene(%Scene{})
    search_changeset = Scene.search_changeset(%Scene{}, %{})
    memberships = Scenes.get_memberships(user.id)

    socket =
      socket
      |> assign(:memberships, memberships)
      |> assign(:create_form, to_form(scene_changeset))
      |> assign(:search_form, to_form(search_changeset))
      |> assign(:search_results, [])

    {:ok, socket}
  end

  def handle_event("validate_scene", params, socket) do
    %{"scene" => scene} = params

    create_form =
      %Scene{}
      |> Scenes.change_scene(scene)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, socket |> assign(:create_form, create_form)}
  end

  def handle_event("create_scene", params, socket) do
    %{"scene" => scene_params} = params

    opts = [
      {:validate_place, true}
      # {:validate_city, true} doesnt work cuz geonames is nice and all and i love what they do but they kinda suck 
    ]

    case Scenes.create_scene(socket.assigns.current_user.id, scene_params, opts) do
      {:ok, _scene} ->
        info = "Scene Created"

        {:noreply,
         socket
         |> assign(:memberships, Scenes.get_memberships(socket.assigns.current_user.id))
         |> put_flash(:info, info)}

      {:error, changeset} ->
        IO.puts("CHANGESET")
        IO.inspect(Keyword.get(changeset.errors, :unique_place_indentifier))

        error =
          "An error occurred while creating the scene, the most likely cause is that it is a duplicate."

        {:noreply,
         socket
         |> put_flash(:error, error)
         |> assign(:create_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("search", params, socket) do
    %{"scene" => scene_params} = params

    changeset =
      %Scene{}
      |> Scene.search_changeset(scene_params)
      |> Map.put(:action, :validate)

    if changeset.valid? do
      results =
        Scenes.search_scene(
          socket.assigns.current_user.id,
          Ecto.Changeset.get_change(changeset, :unique_place_identifier)
        )

      IO.inspect(results)

      {:noreply,
       socket
       |> assign(:search_results, results)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("join_scene", params, socket) do
    %{"id" => scene_id} = params

    case Scenes.join_scene(socket.assigns.current_user.id, scene_id) do
      {:ok, membership} ->
        info = "Successfully joined scene"

        results =
          Enum.map(socket.assigns.search_results, fn m ->
            if m.id == String.to_integer(scene_id) do
              Map.put(m, :member, membership.membership)
            end
          end)

        {:noreply,
         socket
         |> assign(:memberships, socket.assigns.memberships ++ [membership])
         |> assign(:search_results, results)
         |> put_flash(:info, info)}

      {:error, _changest} ->
        error = "Error joining scene"

        {:noreply,
         socket
         |> put_flash(:error, error)}
    end
  end

  def handle_event("leave_scene", params, socket) do
    %{"scene" => scene_id} = params

    case Scenes.delete_membership(socket.assigns.current_user.id, scene_id) do
      {deleted, _} when deleted > 0 ->
        info = "scene left successfully"

        # update both the membership list and search results so everything is always accurate

        updated_memberships =
          Enum.filter(socket.assigns.memberships, fn m ->
            Map.get(m, :scene) != String.to_integer(scene_id)
          end)

        search_results =
          Enum.map(socket.assigns.search_results, fn m ->
            if m.id == String.to_integer(scene_id) do
              Map.put(m, :member, nil)
            end
          end)

        {:noreply,
         socket
         |> put_flash(:info, info)
         |> assign(:memberships, updated_memberships)
         |> assign(:search_results, search_results)}

      {0, _} ->
        error = "there was an error leaving the scene"

        {:noreply, socket |> put_flash(:error, error)}
    end
  end
end
