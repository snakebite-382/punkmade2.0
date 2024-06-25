defmodule Punkmade.Scenes.Scene do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scenes" do
    field :city, :string
    field :parent_scene_id, :integer
    # as iso code
    field :country, :string
    field :unique_place_identifier, :string
    field :state, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def creation_changeset(scene, attrs, opts \\ []) do
    scene
    |> cast(attrs, [:city, :country, :parent_scene_id, :state])
    |> validate_required([:city, :country])
    |> validate_parent()
    |> validate_place(:city)
    |> validate_place(:country)
    |> validate_state()
    |> maybe_validate_country(opts)
    |> maybe_validate_unique_place(opts)
    |> maybe_validate_real_city(opts)
  end

  def search_changeset(scene, attrs) do
    changeset =
      scene
      |> cast(attrs, [:city, :state, :country])
      |> validate_required([:city, :country])
      |> validate_place(:city)
      |> validate_place(:country)
      |> validate_state()

    if get_change(changeset, :city) && get_change(changeset, :state) &&
         get_change(changeset, :country) do
      changeset
      |> put_change(:unique_place_identifier, gen_place_id(changeset))
    else
      changeset
    end
  end

  defp validate_state(changeset) do
    state = get_change(changeset, :state)

    if state do
      changeset
      |> validate_place(:state)
    else
      changeset
      |> put_change(:state, "")
    end
  end

  defp validate_parent(changeset) do
    parent = get_change(changeset, :parent_scene_id)

    if parent do
      changeset
    else
      changeset
      |> put_change(:parent_scene_id, nil)
    end
  end

  defp validate_place(changeset, change) do
    changeset
    |> validate_length(change, max: 255, min: 2)
    |> validate_format(change, ~r/^[A-Za-zÀ-ÖØ-öø-ÿ\'\-\ ]+$/,
      message:
        "must only contain letters (accents are fine), hyphens, spaces, and apostrophes only"
    )
  end

  defp maybe_validate_country(changeset, opts) do
    if Keyword.get(opts, :validate_country, true) do
      country = get_change(changeset, :country)

      if country do
        code = ISO.country_code(country)
        name = ISO.country_name(country)

        cond do
          is_nil(code) && is_nil(name) ->
            changeset |> add_error(:country, "invalid or unsupported country")

          is_nil(name) && code ->
            changeset |> put_change(:country, code)

          is_nil(code) && name ->
            changeset |> put_change(:country, ISO.country_code(name))
        end
      else
        changeset
      end
    else
      changeset
    end
  end

  @geoname_user System.get_env("GEONAME_USER")

  defp maybe_validate_real_city(changeset, opts) do
    if Keyword.get(opts, :validate_city, false) do
      params = [
        formatted: "true",
        name_equals: get_change(changeset, :city),
        country: get_change(changeset, :country),
        maxRows: 10,
        username: @geoname_user
      ]

      IO.puts(@geoname_user)

      case(HTTPoison.get("http://api.geonames.org/searchJSON", [], params: params)) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          data = Jason.decode!(body)

          case data["geonames"] do
            [] -> changeset |> add_error(:city, "invalid or unsupported city")
            _cities -> changeset
          end

        {:ok, %HTTPoison.Response{status_code: status}} ->
          IO.inspect(status)
          changeset |> add_error(:city, "1) error checking city validity")

        {:error, _error} ->
          changeset |> add_error(:city, "2) error checking city validity")
      end
    else
      changeset
    end
  end

  defp gen_place_id(changeset) do
    country = get_change(changeset, :country) |> String.downcase() |> String.trim()

    city = get_change(changeset, :city) |> String.downcase() |> String.trim()

    state = get_change(changeset, :state) |> String.downcase() |> String.trim()

    country <> ":" <> state <> ":" <> city
  end

  defp maybe_validate_unique_place(changeset, opts) do
    if Keyword.get(opts, :validate_place, false) do
      place = gen_place_id(changeset)

      changeset
      |> put_change(:unique_place_identifier, place)
      |> unsafe_validate_unique(:unique_place_identifier, Punkmade.Repo)
      |> unique_constraint(:unique_place_identifier)
    else
      changeset
    end
  end
end
