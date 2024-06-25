defmodule Punkmade.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :full_name, :string
    field :first_name, :string, virtual: true
    field :last_name, :string, virtual: true
    field :bio, :string
    field :pronouns, :string
    field :pronoun_subjective, :string, virtual: true
    field :pronoun_objective, :string, virtual: true
    field :pronoun_possessive, :string, virtual: true
    field :gravatar_url, :string
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :current_password, :string, virtual: true, redact: true
    field :confirmed_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.

  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:username, :first_name, :last_name, :email, :password])
    |> validate_username()
    |> validate_email(opts)
    |> validate_password(opts)
    |> add_gravatar()
    |> validate_name()
  end

  defp add_gravatar(changeset) do
    email = get_change(changeset, :email)

    if email do
      hash =
        :crypto.hash(:sha256, email |> String.trim() |> String.downcase())
        |> Base.encode16(case: :lower)

      changeset
      |> put_change(:gravatar_url, "https://gravatar.com/avatar/" <> hash)
    else
      changeset
    end
  end

  defp validate_name(changset) do
    changset
    |> validate_required([:first_name, :last_name])
    |> validate_length(:first_name, max: 50, min: 2)
    |> validate_length(:last_name, max: 50, min: 2)
    |> validate_format(:first_name, ~r/^[A-Za-zÀ-ÖØ-öø-ÿ\'\-]+$/,
      message: "must contain letters (accents are fine), hyphens and apostrophes only"
    )
    |> validate_format(:last_name, ~r/^[A-Za-zÀ-ÖØ-öø-ÿ\'\-]+$/,
      message: "must contain letters (accents are fine), hyphens and apostrophes only"
    )
    |> concat_names()
  end

  defp concat_names(changset) do
    first_name = get_change(changset, :first_name)
    last_name = get_change(changset, :last_name)

    if first_name && last_name do
      full_name = first_name <> " " <> last_name

      changset
      |> put_change(:full_name, full_name)
    else
      changset
    end
  end

  defp validate_username(changeset) do
    changeset
    |> validate_required([:username])
    |> validate_length(:username, max: 32, min: 2)
    |> unsafe_validate_unique(:username, Punkmade.Repo)
    |> unique_constraint(:username)
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 72)
    # Examples of additional password validation:
    |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/,
      message: "at least one digit or punctuation character"
    )
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, Punkmade.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  defp validate_changed(changeset, value) do
    changeset
    |> case do
      %{changes: %{^value => _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, value, "did not change")
    end
  end

  def bio_changeset(user, attrs) do
    user
    |> cast(attrs, [:bio])
    |> validate_required(:bio)
    |> validate_length(:bio, max: 255, min: 0)
    |> validate_changed(:bio)
  end

  @doc """
  A user changeset to update the username 

  if the username doesn't change an error is added
  """
  def username_changeset(user, attrs) do
    user
    |> cast(attrs, [:username])
    |> validate_username()
    |> validate_changed(:username)
  end

  @doc """
  A user changeset to update pronouns

  if the pronouns don't change an error is added
  """

  def pronoun_changeset(user, attrs) do
    user
    |> cast(attrs, [:pronoun_subjective, :pronoun_objective, :pronoun_possessive])
    |> validate_pronoun(:pronoun_subjective)
    |> validate_pronoun(:pronoun_objective)
    |> validate_pronoun(:pronoun_possessive)
    |> concat_pronouns()
    |> validate_changed(:pronouns)
  end

  defp validate_pronoun(changeset, pronoun) do
    changeset
    |> validate_required(pronoun)
    |> validate_format(:first_name, ~r/^[A-Za-zÀ-ÖØ-öø-ÿ]+$/,
      message: "Must be only letters (accents are fine)"
    )
    |> validate_length(pronoun, min: 2, max: 6)
  end

  defp concat_pronouns(changeset) do
    subjective = get_change(changeset, :pronoun_subjective)
    objective = get_change(changeset, :pronoun_objective)
    possessive = get_change(changeset, :pronoun_possessive)

    if subjective && objective && possessive do
      pronouns = subjective <> "/" <> objective <> "/" <> possessive

      changeset
      |> put_change(:pronouns, pronouns)
    else
      changeset
    end
  end

  @doc """
  A user changeset to update teh users name

  errors if the name doesn't change
  """

  def full_name_changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required(:first_name)
    |> validate_required(:last_name)
    |> validate_name()
    |> validate_changed(:full_name)
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> validate_changed(:email)
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Punkmade.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    changeset = cast(changeset, %{current_password: password}, [:current_password])

    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
