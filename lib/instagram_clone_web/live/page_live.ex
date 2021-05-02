defmodule InstagramCloneWeb.PageLive do
  alias InstagramClone.Accounts
  alias InstagramClone.Accounts.User

  use InstagramCloneWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    changeset = Accounts.change_user_registration(%User{})
    {:ok,
     socket
     |> assign(changeset: changeset)
     |> assign(trigger_submit: true)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %User{}
      |> User.registration_changeset(user_params)
      |> Map.put(:action, :validate)

    # :timer.sleep(9000)
    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("save", _, socket) do
    {:noreply, assign(socket, trigger_submit: true)}
  end
end
