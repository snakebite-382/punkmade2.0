defmodule PunkmadeWeb.UserSettingsLive do
  use PunkmadeWeb, :live_view

  alias Punkmade.Accounts

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)
    username_changeset = Accounts.change_username(user)
    full_name_changeset = Accounts.change_full_name(user)
    bio_changeset = Accounts.change_bio(user)
    pronouns_changeset = Accounts.change_pronouns(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:username_form, to_form(username_changeset))
      |> assign(:full_name_form, to_form(full_name_changeset))
      |> assign(:bio_form, to_form(bio_changeset))
      |> assign(:pronouns_form, to_form(pronouns_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_full_name", params, socket) do
    %{"user" => user_params} = params

    full_name_form =
      socket.assigns.current_user
      |> Accounts.change_full_name(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, full_name_form: full_name_form)}
  end

  def handle_event("update_full_name", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_full_name(user, user_params) do
      {:ok, new_user} ->
        info = "Your full name has been updated"

        {:noreply, socket |> put_flash(:info, info) |> assign(:current_user, new_user)}

      {:error, changeset} ->
        error =
          "An error occurred while updating your name, double check your inputs are valid, and that your name changes"

        {:noreply,
         socket
         |> put_flash(:error, error)
         |> assign(:full_name_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_pronouns", params, socket) do
    %{"user" => user_params} = params

    pronouns_form =
      socket.assigns.current_user
      |> Accounts.change_pronouns(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, pronouns_form: pronouns_form)}
  end

  def handle_event("update_pronouns", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_pronouns(user, user_params) do
      {:ok, new_user} ->
        info = "Your pronouns have been updated"

        {:noreply, socket |> put_flash(:info, info) |> assign(:current_user, new_user)}

      {:error, changeset} ->
        error =
          "An error occurred while updating your pronouns, double check your inputs are valid and your pronouns change"

        {:noreply,
         socket
         |> put_flash(:error, error)
         |> assign(:pronouns_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_bio", params, socket) do
    %{"user" => user_params} = params

    bio_form =
      socket.assigns.current_user
      |> Accounts.change_bio(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, bio_form: bio_form)}
  end

  def handle_event("update_bio", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_bio(user, user_params) do
      {:ok, new_user} ->
        info = "Your bio has been updated"

        {:noreply, socket |> put_flash(:info, info) |> assign(:current_user, new_user)}

      {:error, changeset} ->
        error = "There was an error updating your bio"

        {:noreply,
         socket
         |> put_flash(:error, error)
         |> assign(:bio_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_username", params, socket) do
    %{"user" => user_params} = params

    username_form =
      socket.assigns.current_user
      |> Accounts.change_username(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, username_form: username_form)}
  end

  def handle_event("update_username", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_username(user, user_params) do
      {:ok, new_user} ->
        info = "Your username has been updated"
        {:noreply, socket |> put_flash(:info, info) |> assign(:current_user, new_user)}

      {:error, changeset} ->
        {:noreply, assign(socket, :username_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
