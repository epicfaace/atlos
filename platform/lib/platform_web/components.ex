defmodule PlatformWeb.Components do
  use Phoenix.Component
  use Phoenix.HTML

  alias PlatformWeb.Router.Helpers, as: Routes
  alias Platform.Accounts
  alias Platform.Material.Attribute
  alias Platform.Material.Media
  alias Platform.Material

  def navlink(%{request_path: path, to: to} = assigns) do
    classes =
      if String.starts_with?(path, to) and !String.equivalent?(path, "/") do
        "bg-neutral-800 text-white group w-full p-3 rounded-md flex flex-col items-center text-xs font-medium"
      else
        "text-neutral-100 hover:bg-neutral-800 hover:text-white group w-full p-3 rounded-md flex flex-col items-center text-xs font-medium"
      end

    ~H"""
    <%= link to: @to, class: classes do %>
      <%= render_slot(@inner_block) %>
      <span class="mt-2"><%= @label %></span>
    <% end %>
    """
  end

  def modal(assigns) do
    ~H"""
    <div class="fixed z-10 inset-0 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" aria-hidden="true"></div>

        <!-- This element is to trick the browser into centering the modal contents. -->
        <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>

        <!-- add phx-click-away="close_modal" phx-window-keydown="close_modal" phx-key="Escape" phx-target={@target}, just need to get confirmation warning right -->
        <div class="relative inline-block align-bottom bg-white rounded-lg px-4 pt-5 pb-4 text-left shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-xl sm:w-full sm:p-6">
          <div class="hidden sm:block absolute top-0 right-0 pt-4 pr-4">
            <button type="button" class="bg-white rounded-md text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" phx-click="close_modal" phx-target={@target} data-confirm={@close_confirmation}>
              <span class="sr-only">Close</span>
              <!-- Heroicon name: outline/x -->
              <svg class="h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  def card(assigns) do
    assigns =
      assigns
      |> assign_new(:header, fn -> [] end)
      |> assign_new(:no_pad, fn -> false end)

    ~H"""
    <div class="bg-white overflow-hidden shadow rounded-lg divide-y divide-gray-200">
      <%= unless Enum.empty?(@header) do %>
      <div class="py-4 px-5 sm:py-5">
        <%= render_slot(@header) %>
      </div>
      <% end %>
      <div class={if @no_pad, do: "", else: "py-4 px-5 sm:py-5"}>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  def notification(assigns) do
    assigns =
      assigns
      |> assign_new(:title, fn -> "" end)
      |> assign_new(:right, fn -> [] end)

    icon =
      case assigns[:type] do
        _ ->
          ~H"""
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-info-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          """
      end

    ~H"""
    <div class="max-w-sm w-full bg-white shadow-lg rounded-lg pointer-events-auto ring-1 ring-black ring-opacity-5 overflow-hidden">
      <div class="p-4">
        <div class="flex items-start">
          <div class="flex-shrink-0">
            <%= icon %>
          </div>
          <div class="ml-3 w-0 flex-1 pt-0.5">
            <%= if String.length(@title) > 0 do %>
            <p class="text-sm font-medium text-gray-900 mb-1"><%= @title %></p>
            <% end %>
            <p class="text-sm text-gray-500"><%= render_slot(@inner_block) %></p>
          </div>
          <%= render_slot(@right) %>
        </div>
      </div>
    </div>
    """
  end

  def nav(assigns) do
    ~H"""
    <div class="w-28"></div>
    <div class="hidden w-28 bg-neutral-700 overflow-y-auto md:block fixed h-screen">
        <div class="w-full py-6 flex flex-col items-center">
            <%= link to: "/", class: "flex flex-col items-center text-white" do %>
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span class="text-white uppercase font-bold">Atlos</span>
            <% end %>
            <div class="flex-1 mt-6 w-full px-2 space-y-1">
            <.navlink to="/new" label="New" request_path={@path}>
                <svg class="text-white group-hover:text-white h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
                </svg>
            </.navlink>

            <a href="#" class="text-neutral-100 hover:bg-neutral-800 hover:text-white group w-full p-3 rounded-md flex flex-col items-center text-xs font-medium">
                <svg class="text-neutral-300 group-hover:text-white h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />
                </svg>
                <span class="mt-2">Queue</span>
            </a>

            <.navlink to="/media" label="All Media" request_path={@path}>
              <svg class="text-neutral-300 group-hover:text-white h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
            </.navlink>

            <a href="#" class="text-neutral-100 hover:bg-neutral-800 hover:text-white group w-full p-3 rounded-md flex flex-col items-center text-xs font-medium">
                <svg class="text-neutral-300 group-hover:text-white h-6 w-6" xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                </svg>
                <span class="mt-2">Watchlist</span>
            </a>

            <.navlink to="/notifications" label="Notifications" request_path={@path}>
                <svg class="text-neutral-300 group-hover:text-white h-6 w-6" xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                </svg>
            </.navlink>

            <.navlink to="/settings" label="Settings" request_path={@path}>
                <svg class="text-neutral-300 group-hover:text-white h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
            </.navlink>
            </div>
        </div>
    </div>
    """
  end

  def stepper(%{options: options, active: active} = assigns) do
    active_index = Enum.find_index(options, &String.equivalent?(&1, active))

    ~H"""
        <nav aria-label="Progress">
          <ol role="list" class="border border-gray-300 rounded-md divide-y divide-gray-300 md:flex md:divide-y-0 bg-white">
            <%= for {item, index} <- Enum.with_index(options) do %>
              <li class="relative md:flex-1 md:flex">
                <%= if index < active_index do %>
                  <!-- Completed Step -->
                  <div class="group flex items-center w-full">
                    <span class="px-6 py-4 flex items-center text-sm font-medium">
                      <span class="flex-shrink-0 w-10 h-10 flex items-center justify-center bg-urge-600 rounded-full ">
                        <!-- Heroicon name: solid/check -->
                        <svg class="w-6 h-6 text-white" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                          <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                        </svg>
                      </span>
                      <span class="ml-4 text-sm font-medium text-gray-900"><%= item %></span>
                    </span>
                  </div>
                <% end %>

                <%= if index == active_index do %>
                  <!-- Current Step -->
                  <div class="px-6 py-4 flex items-center text-sm font-medium" aria-current="step">
                    <span class="flex-shrink-0 w-10 h-10 flex items-center justify-center border-2 border-urge-600 rounded-full">
                      <span class="text-urge-600"><%= index + 1 %></span>
                    </span>
                    <span class="ml-4 text-sm font-medium text-urge-600"><%= item %></span>
                  </div>
                <% end %>

                <%= if index > active_index do %>
                  <!-- Upcoming Step -->
                  <div class="group flex items-center">
                    <span class="px-6 py-4 flex items-center text-sm font-medium">
                      <span class="flex-shrink-0 w-10 h-10 flex items-center justify-center border-2 border-gray-300 rounded-full">
                        <span class="text-gray-500"><%= index + 1 %></span>
                      </span>
                      <span class="ml-4 text-sm font-medium text-gray-500"><%= item %></span>
                    </span>
                  </div>
                <% end %>

                <%= if index != length(options) - 1 do %>
                  <!-- Arrow separator for lg screens and up -->
                  <div class="hidden md:block absolute top-0 right-0 h-full w-5" aria-hidden="true">
                    <svg class="h-full w-full text-gray-300" viewBox="0 0 22 80" fill="none" preserveAspectRatio="none">
                      <path d="M0 -2L20 40L0 82" vector-effect="non-scaling-stroke" stroke="currentcolor" stroke-linejoin="round" />
                    </svg>
                  </div>
                <% end %>
              </li>
            <% end %>
          </ol>
        </nav>
    """
  end

  defp naive_pluralise(amt, word) when amt == 1, do: word
  defp naive_pluralise(_amt, word), do: word <> "s"

  defp time_ago_in_words(seconds) when seconds < 60 do
    "just now"
  end

  defp time_ago_in_words(seconds) when seconds < 3600 do
    amt = round(seconds / 60)
    "#{amt} #{naive_pluralise(amt, "minute")} ago"
  end

  defp time_ago_in_words(seconds) when seconds < 86400 do
    amt = round(seconds / 3600)
    "#{amt} #{naive_pluralise(amt, "hour")} ago"
  end

  defp time_ago_in_words(seconds) do
    amt = round(seconds / 86400)
    "#{amt} #{naive_pluralise(amt, "day")} ago"
  end

  defp seconds_ago(datetime) do
    {start, _} = DateTime.to_gregorian_seconds(DateTime.utc_now())
    {now, _} = DateTime.to_gregorian_seconds(DateTime.from_naive!(datetime, "Etc/UTC"))
    start - now
  end

  def rel_time(%{time: time} = assigns) do
    ago = time |> seconds_ago()

    months = %{
      1 => "Jan",
      2 => "Feb",
      3 => "Mar",
      4 => "Apr",
      5 => "May",
      6 => "Jun",
      7 => "Jul",
      8 => "Aug",
      9 => "Sep",
      10 => "Oct",
      11 => "Nov",
      12 => "Dec"
    }

    if ago > 7 * 24 * 60 * 60 do
      ~H"""
        <span title={@time}><%= months[@time.month] %> <%= @time.day %> <%= @time.year %></span>
      """
    else
      ~H"""
        <span title={@time}><%= ago |> time_ago_in_words() %></span>
      """
    end
  end

  def location(%{lat: lat, lon: lon} = assigns) do
    ~H"""
    <%= lon %>, <%= lat %> &nearr;
    """
  end

  def attr_entry(%{name: name, value: value} = assigns) do
    attr = Attribute.get_attribute(name)

    ~H"""
    <span class="inline-flex flex-wrap gap-1">
      <%= case attr.type do %>
      <% :text -> %>
        <div class="inline-block">
          <%= value %>
        </div>
      <% :select -> %>
        <div class="inline-block">
          <div class="chip ~neutral inline-block"><%= value %></div>
        </div>
      <% :multi_select -> %>
        <%= for item <- value do %>
            <div class="chip ~neutral inline-block"><%= item %></div>
        <% end %>
      <% :location -> %>
        <div class="inline-block">
          <% {lon, lat} = value.coordinates %>
          <a class="chip ~neutral inline-block flex gap-1" target="_blank" href={"https://maps.google.com/maps?q=#{lat},#{lon}"}>
            <.location lat={lat} lon={lon} />
          </a>
        </div>
      <% :time -> %>
        <div class="inline-block">
          <div class="chip ~neutral inline-block"><%= value %></div>
        </div>
      <% :date -> %>
        <div class="inline-block">
          <div class="chip ~neutral inline-block"><%= value %></div>
        </div>
      <% end %>
    </span>
    """
  end

  def text_diff(%{old: old, new: new} = assigns) do
    diff = String.myers_difference(old || "", new || "")

    ~H"""
    <span class="text-sm">
      <%= for {action, elem} <- diff do %>
        <%= case action do %>
          <% :ins -> %>
            <span class="px-1 text-blue-800 bg-blue-200 rounded-sm">
              <%= elem %>
            </span>
          <% :del -> %>
            <span class="px-1 text-yellow-800 bg-yellow-200 rounded-sm line-through">
              <%= elem %>
            </span>
          <% :eq -> %>
            <span class="text-gray-700 px-0 text-sm">
              <%= elem %>
            </span>
        <% end %>
      <% end %>
    </span>
    """
  end

  def list_diff(%{old: old, new: new} = assigns) do
    clean = fn x ->
      cleaned = if is_nil(x), do: [], else: x
      cleaned |> Enum.filter(&(!(is_nil(&1) || &1 == ""))) |> Enum.sort()
    end

    diff = List.myers_difference(clean.(old), clean.(new))

    ~H"""
    <span class="flex flex-wrap gap-1">
      <%= for {action, elem} <- diff do %>
        <%= case action do %>
          <% :eq -> %>
            <%= for item <- elem do %>
              <span class="chip ~neutral inline-block text-xs">
                <%= item %>
              </span>
            <% end %>
          <% :ins -> %>
            <%= for item <- elem do %>
              <span class="chip ~blue inline-block text-xs">
                + <%= item %>
              </span>
            <% end %>
          <% :del -> %>
            <%= for item <- elem do %>
              <span class="chip ~yellow inline-block text-xs">
                - <%= item %>
              </span>
            <% end %>
        <% end %>
      <% end %>
    </span>
    """
  end

  def location_diff(%{old: old, new: new} = assigns) do
    ~H"""
    <span>
      <%= case old do %>
        <% %{"coordinates" => [lon, lat]} -> %>
          <a class="chip ~yellow inline-flex text-xs" target="_blank" href={"https://maps.google.com/maps?q=#{lat},#{lon}"}>
            - <.location lat={lat} lon={lon} />
          </a>
        <% _x -> %>
      <% end %>
      <%= case new do %>
        <% %{"coordinates" => [lon, lat]} -> %>
          <a class="chip ~blue inline-flex text-xs" target="_blank" href={"https://maps.google.com/maps?q=#{lat},#{lon}"}>
            + <.location lat={lat} lon={lon} />
          </a>
        <% _x -> %>
      <% end %>
    </span>
    """
  end

  def attr_diff(%{name: name, old: old, new: new} = assigns) do
    attr = Attribute.get_attribute(name)

    ~H"""
    <span>
      <%= case attr.type do %>
        <% :text -> %> <.text_diff old={old} new={new} />
        <% :select -> %> <.list_diff old={[old]} new={[new]} />
        <% :multi_select -> %> <.list_diff old={old} new={new} />
        <% :location -> %> <.location_diff old={old} new={new} />
        <% :time -> %> <.list_diff old={[old]} new={[new]} />
        <% :date -> %> <.list_diff old={[old]} new={[new]} />
      <% end %>
    </span>
    """
  end

  def update_stream(%{updates: updates} = assigns) do
    ~H"""
    <div class="flow-root">
      <ul role="list" class="-mb-8">
        <%= for update <- updates do %>
        <li>
          <div class="relative pb-8">
            <span class="absolute top-5 left-5 -ml-px h-full w-0.5 bg-gray-200" aria-hidden="true"></span>
            <div class="relative flex items-start space-x-3">
              <div class="relative">
                <img class="h-10 w-10 rounded-full bg-gray-400 flex items-center justify-center ring-8 ring-white shadow" src={Accounts.get_profile_photo_path(update.user)} alt={"Profile photo for #{update.user.username}"}>
              </div>
              <div class="min-w-0 flex-1 flex flex-col">
                <div>
                  <div class="text-sm text-gray-600 mt-2">
                    <a class="font-medium text-gray-900"><%= update.user.username %></a>
                    <%= case update.type do %>
                      <% :update_attribute -> %>
                        updated
                        <%= live_patch class: "text-button text-gray-800 inline-block", to: Routes.media_show_path(@socket, :edit, update.media.slug, update.modified_attribute) do %>
                          <%= Attribute.get_attribute(update.modified_attribute).label %>
                        <% end %>
                      <% :create -> %>
                        added <span class="font-medium text-gray-900"><%= update.media.slug %></span>
                      <% :upload_version -> %>
                        uploaded a version
                      <% :comment -> %>
                        commented
                    <% end %>
                    <.rel_time time={update.inserted_at} />
                  </div>
                </div>

                <%= if update.type == :update_attribute || update.explanation do %>
                  <div class="mt-1 text-sm text-gray-700 border border-gray-300 rounded-lg shadow-sm overflow-hidden flex flex-col divide-y">
                    <!-- Update detail section -->
                    <%= if update.type == :update_attribute do %>
                      <div class="bg-gray-50 p-2 flex">
                        <div class="flex-grow">
                          <.attr_diff name={update.modified_attribute} old={Jason.decode!(update.old_value)} new={Jason.decode!(update.new_value)} />
                        </div>
                      </div>
                    <% end %>

                    <!-- Text comment section -->
                    <%= if update.explanation do %>
                      <div class="p-2">
                        <p><%= update.explanation %></p>
                      </div>
                    <% end %>
                  </div>
                <% end %>
              </div>
            </div>
          </div>
        </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def media_card(%{media: %Media{} = media} = assigns) do
    # TODO: use live_redirect
    # TODO: preload
    contributors = Material.contributors(media)
    ratio = Media.attribute_ratio(media)
    sensitive = Media.is_sensitive(media)

    ~H"""
      <a class="flex group flex-col items-center md:flex-row bg-white overflow-hidden shadow rounded-lg justify-between" href={"/media/#{media.slug}"}>
        <div class="h-full p-2 flex flex-col w-full md:w-3/4 gap-2">
          <section>
            <p class="font-mono text-xs text-gray-500"><%= media.slug %></p>
            <p class="font-medium text-gray-700 group-hover:text-gray-900"><%= media.description %></p>
          </section>
          <section class="flex flex-wrap gap-1 self-start align-top">
            <%= if sensitive do %>
              <%= for item <- media.attr_sensitive do %>
                <span class="badge ~warning">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3 mr-px" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M20.618 5.984A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016zM12 9v2m0 4h.01" />
                  </svg>

                  <%= item %>
                </span>
              <% end %>
            <% end %>

            <%= if media.attr_geolocation do %>
              <span class="badge ~info">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3 mr-px" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M5.05 4.05a7 7 0 119.9 9.9L10 18.9l-4.95-4.95a7 7 0 010-9.9zM10 11a2 2 0 100-4 2 2 0 000 4z" clip-rule="evenodd" />
                </svg>

                Geolocated
              </span>
            <% end %>

            <%= if media.attr_date_recorded do %>
              <span class="badge ~info">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3 mr-px" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd" />
                </svg>

                Chronolocated
              </span>
            <% end %>

            <span class="badge ~neutral">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3 mr-px" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z" />
              </svg>

              <%= cond do %>
                <% ratio < 0.3 -> %> Low
                <% ratio < 0.6 -> %> Medium
                <% ratio < 1 -> %> High
                <% true -> %> Complete
              <% end %>

              (<%= length(Attribute.set_for_media(media)) %>/<%= length(Attribute.attribute_names()) %>)
            </span>
          </section>
          <section class="flex-grow" />
          <section class="flex gap-2 justify-between items-center">
            <.user_stack users={contributors} />
            <p class="text-xs text-gray-500 flex items-center">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-px text-gray-400" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd" />
              </svg>
              <.rel_time time={media.updated_at} />
            </p>
          </section>
        </div>

        <% thumb = Material.media_thumbnail(media) %>
        <div class="hidden md:block h-full md:w-1/4">
          <%= if thumb do %>
            <img class="sr-hide object-cover h-full w-full rounded-t-lg md:rounded-none md:rounded-r-lg" src={thumb}>
          <% else %>
            <div class="bg-gray-200 flex items-center justify-around h-full w-full rounded-t-lg md:rounded-none md:rounded-r-lg text-gray-500">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
          <% end %>
        </div>
      </a>
    """
  end

  def user_stack(assigns) do
    ~H"""
    <div class="flex -space-x-1 relative z-0 overflow-hidden">
      <%= for user <- @users do %>
        <img class="relative z-30 inline-block h-6 w-6 rounded-full ring-2 ring-white" src={Accounts.get_profile_photo_path(user)} alt={"Profile photo for #{user.username}"}>
      <% end %>
    </div>
    """
  end
end
