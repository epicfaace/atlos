defmodule PlatformWeb.MediaLive.Queue do
  use PlatformWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    which = Map.get(params, "which", "help_needed")

    {:noreply,
     socket
     |> assign(:title, "Queue")
     |> assign(:tab, which)
     |> assign(:query, query_for_which(which))}
  end

  def which_to_title(which) do
    case which do
      "help_needed" -> "Help Needed"
      "needs_confirmation" -> "Needs Confirmation"
      "community_confirmed" -> "Community Confirmed"
    end
  end

  defp query_for_which(which) do
    case which do
      "help_needed" -> %{"attr_flag" => "Help Needed"}
      "needs_confirmation" -> %{"attr_flag" => "Needs Confirmation"}
      "community_confirmed" -> %{"attr_flag" => "Community Confirmed"}
    end
  end

  def render(assigns) do
    ~H"""
    <article class="w-full max-w-screen-xl px-8">
      <div>
        <div class="border-b border-gray-200 flex flex-col md:flex-row mb-8 items-baseline">
          <h1 class="text-3xl flex-grow font-medium md:mr-8">Queue</h1>
          <nav class="-mb-px flex space-x-8" aria-label="Tabs">
            <% active_classes =
              "border-urge-500 text-urge-600 whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm" %>
            <% inactive_classes =
              "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm" %>
            <%= live_patch("Help Needed",
              class: if(@tab == "help_needed", do: active_classes, else: inactive_classes),
              to: "/queue/help_needed"
            ) %>
            <%= live_patch("Needs Confirmation",
              class: if(@tab == "needs_confirmation", do: active_classes, else: inactive_classes),
              to: "/queue/needs_confirmation"
            ) %>
            <%= live_patch("Community Confirmed",
              class: if(@tab == "community_confirmed", do: active_classes, else: inactive_classes),
              to: "/queue/community_confirmed"
            ) %>
          </nav>
        </div>
      </div>
      <.live_component
        module={PlatformWeb.MediaLive.PaginatedMediaList}
        id="media-list"
        current_user={@current_user}
        query_params={@query}
      />
    </article>
    """
  end
end
