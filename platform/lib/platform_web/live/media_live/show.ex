defmodule PlatformWeb.MediaLive.Show do
  use PlatformWeb, :live_view

  alias Phoenix.PubSub

  alias Platform.Material
  alias Material.Attribute
  alias PlatformWeb.MediaLive.EditAttribute
  alias Material.Media
  alias Platform.Accounts
  alias Accounts.User
  alias Platform.Notifications

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"slug" => slug} = params, _uri, socket) do
    {:noreply,
     socket
     |> assign(:slug, slug)
     |> assign(:attribute, Map.get(params, "attribute"))
     |> assign(:title, "Incident #{slug}")
     # This forces the comment box to be fully rerendered on submit
     #  |> assign(:comment_box_id, Utils.generate_random_sequence(10))
     |> assign_media_and_updates()}
  end

  defp filter_editable(attributes, media, %User{} = user) do
    attributes
    |> Enum.filter(fn attr ->
      Attribute.can_user_edit(attr, user, media)
    end)
  end

  defp sort_by_date(items) do
    items |> Enum.sort_by(& &1.updated_at) |> Enum.reverse()
  end

  defp filter_viewable_versions(versions, %User{} = user) do
    versions |> Enum.filter(&Material.MediaVersion.can_user_view(&1, user))
  end

  defp subscribe_to_media(socket, media) do
    if not Map.get(socket.assigns, :pubsub_subscribed, false) do
      PubSub.subscribe(Platform.PubSub, Material.pubsub_topic_for_media(media.id))
      socket |> assign(:pubsub_subscribed, true)
    else
      socket
    end
  end

  defp assign_media_and_updates(socket) do
    with %Material.Media{} = media <- Material.get_full_media_by_slug(socket.assigns.slug),
         true <- Media.can_user_view(media, socket.assigns.current_user) do
      # Mark notifications for this media as read
      Notifications.mark_notifications_as_read(socket.assigns.current_user, media)

      socket
      |> assign(:media, media)
      |> assign(:updates, media.updates |> Enum.sort_by(& &1.inserted_at))
      |> subscribe_to_media(media)
    else
      _ ->
        socket
        |> put_flash(:error, "This incident does not exist or is not available.")
        |> redirect(to: "/")
    end
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply,
     socket |> push_patch(to: Routes.media_show_path(socket, :show, socket.assigns.media.slug))}
  end

  def handle_event(
        "set_media_visibility",
        %{"version" => version, "state" => value} = _params,
        socket
      ) do
    version = Material.get_media_version!(version)

    if (!Accounts.is_privileged(socket.assigns.current_user) && version.visibility == :removed) or
         !Media.can_user_edit(socket.assigns.media, socket.assigns.current_user) do
      {:noreply,
       socket |> put_flash(:error, "You cannot change this media version's visibility.")}
    else
      {:ok, _} =
        case value do
          "visible" ->
            Material.update_media_version(version, %{visibility: value})

          "hidden" ->
            Material.update_media_version(version, %{visibility: value})

          "removed" ->
            if Accounts.is_privileged(socket.assigns.current_user) do
              Material.update_media_version(version, %{visibility: value})
            else
              raise "no permission"
            end
        end

      {:noreply,
       socket
       |> assign_media_and_updates()
       |> put_flash(:info, "Media visibility changed successfully.")}
    end
  end

  def handle_info({:version_created, _version}, socket) do
    {:noreply,
     socket
     |> put_flash(
       :info,
       "Added media successfully. Atlos will archive and process it in the background."
     )
     |> push_patch(to: Routes.media_show_path(socket, :show, socket.assigns.media.slug))}
  end

  def handle_info({:version_creation_failed, _changeset}, socket) do
    {:noreply,
     socket
     |> put_flash(:error, "Unable to process the given media. Please try again.")
     |> push_patch(to: Routes.media_show_path(socket, :show, socket.assigns.media.slug))}
  end

  def handle_info({:media_updated}, socket) do
    {:noreply,
     socket
     |> assign_media_and_updates()}
  end
end
