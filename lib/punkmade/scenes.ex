defmodule Punkmade.Scenes do
  @moduledoc """
  The Scenes context.
  """

  import Ecto.Query, warn: false
  alias Punkmade.Repo

  alias Punkmade.Scenes.Scene

  @doc """
  Returns the list of scenes.

  ## Examples

      iex> list_scenes()
      [%Scene{}, ...]

  """
  def list_scenes do
    Repo.all(Scene)
  end

  @doc """
  Gets a single scene.

  Raises `Ecto.NoResultsError` if the Scene does not exist.

  ## Examples

      iex> get_scene!(123)
      %Scene{}

      iex> get_scene!(456)
      ** (Ecto.NoResultsError)

  """
  def get_scene!(id), do: Repo.get!(Scene, id)

  @doc """
  Creates a scene.

  ## Examples

      iex> create_scene(%{field: value})
      {:ok, %Scene{}}

      iex> create_scene(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_scene(attrs \\ %{}) do
    %Scene{}
    |> Scene.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a scene.

  ## Examples

      iex> update_scene(scene, %{field: new_value})
      {:ok, %Scene{}}

      iex> update_scene(scene, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_scene(%Scene{} = scene, attrs) do
    scene
    |> Scene.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a scene.

  ## Examples

      iex> delete_scene(scene)
      {:ok, %Scene{}}

      iex> delete_scene(scene)
      {:error, %Ecto.Changeset{}}

  """
  def delete_scene(%Scene{} = scene) do
    Repo.delete(scene)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking scene changes.

  ## Examples

      iex> change_scene(scene)
      %Ecto.Changeset{data: %Scene{}}

  """
  def change_scene(%Scene{} = scene, attrs \\ %{}) do
    Scene.changeset(scene, attrs)
  end
end
