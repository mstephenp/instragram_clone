defmodule InstagramCloneWeb.UserLive.Settings do

  use InstagramCloneWeb, :live_view

  alias InstagramClone.Accounts
  alias InstagramClone.Accounts.User
  alias InstagramCloneWeb.Uploaders.Avatar

  @extension_whitelist ~w(.jpg .jpeg .png)

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    changeset = Accounts.change_user(socket.assigns.current_user)

    {:ok,
      socket
      |> assign(changeset: changeset)
      |> assign(page_title: "Edit Profile")
      |> allow_upload(:avatar_url,
      accept: @extension_whitelist,
      max_file_size: 9_000_000,
      progress: &handle_progress/3,
      auto_upload: true)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.current_user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.update_user(socket.assigns.current_user, user_params) do
      {:ok, _user} ->
        {:noreply,
          socket
          |> put_flash(:info, "User updated successfully")
          |> push_redirect(to: Routes.live_path(socket, InstagramCloneWeb.UserLive.Settings))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end

  @impl true
  def handle_event("upload_avatar", _params, socket) do
    {:noreply, socket}
  end

  def handle_progress(:avatar_url, entry, socket) do
    if entry.done? do
      avatar_url = Avatar.get_avatar_url(socket, entry)
      user_params = %{"avatar_url" => avatar_url}

      case Accounts.update_user(socket.assigns.current_user, user_params) do
        {:ok, _user} ->
          Avatar.update(socket, socket.assigns.current_user.avatar_url, entry)
          current_user = Accounts.get_user!(socket.assigns.current_user.id)
          {:noreply,
            socket
            |> put_flash(:info, "Avatar updated successfully")
            |> assign(current_user: current_user)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, socket |> assign(changeset: changeset)}
      end
    else
      {:noreply, socket}
    end
  end
end
