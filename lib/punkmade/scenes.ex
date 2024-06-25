defmodule Punkmade.Scenes do
  @moduledoc """
  The Scenes context.
  """

  import Ecto.Query, warn: false
  alias Punkmade.Scenes.Membership
  alias Punkmade.Repo
  alias Punkmade.Scenes

  alias Punkmade.Scenes.Scene

  @doc """
  takes in a user id and lists all scene memberships
  """

  def get_memberships(user_id) do
    query =
      from membership in Punkmade.Scenes.Membership,
        where: membership.user_id == ^user_id,
        select: membership

    Repo.all(query)
  end

  @doc """
  Gets a single scene.

  Raises `Ecto.NoResultsError` if the Scene does not exist.
  """
  def get_scene!(id), do: Repo.get!(Scene, id)

  @doc """
  Creates a scene.
  """
  def create_scene(user_id, attrs \\ %{}, opts \\ []) do
    %Scene{}
    |> Scene.creation_changeset(attrs, opts)
    |> Repo.insert()
    |> case do
      {:ok, scene} ->
        %Membership{}
        |> Scenes.change_membership(%{user_id: user_id, scene_id: scene.id})
        |> Repo.insert()
        |> case do
          {:ok, _membership} ->
            {:ok, scene}

          {:error, changeset} ->
            Repo.delete(scene)
            {:error, changeset}
        end

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def search_scene(place_id \\ "") do
    query =
      from scene in Scenes.Scene,
        where: like(scene.unique_place_identifier, ^place_id),
        select: [scene.id, scene.city, scene.country, scene.state]

    Repo.all(query)
  end

  @doc """
  Updates a scene.
  """
  def update_scene(%Scene{} = scene, attrs) do
    scene
    |> Scene.creation_changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, %{scene: scene}} ->
        {:ok, scene}

      {:error, :scene, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking scene changes.
  """
  def change_scene(%Scene{} = scene, attrs \\ %{}, opts \\ []) do
    Scene.creation_changeset(scene, attrs, opts)
  end

  alias Punkmade.Scenes.Membership

  @doc """
  Creates a membership.
  """
  def create_membership(attrs \\ %{}) do
    %Membership{}
    |> Membership.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a membership.
  """
  def update_membership(%Membership{} = membership, attrs) do
    membership
    |> Membership.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a membership.
  """
  def delete_membership(%Membership{} = membership) do
    Repo.delete(membership)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking membership changes.
  """
  def change_membership(%Membership{} = membership, attrs \\ %{}) do
    Membership.changeset(membership, attrs)
  end
end
