defmodule Platform.Updates do
  @moduledoc """
  The Updates context.
  """

  import Ecto.Query, warn: false
  alias Platform.Repo

  alias Platform.Utils
  alias Platform.Updates.Update
  alias Platform.Material.Media
  alias Platform.Material.MediaVersion
  alias Platform.Accounts.User
  alias Platform.Material

  @doc """
  Returns the list of updates.

  ## Examples

      iex> list_updates()
      [%Update{}, ...]

  """
  def list_updates do
    Repo.all(Update)
  end

  defp preload_fields(queryable) do
    queryable |> preload([:user, :media, :media_version])
  end

  @doc """
  Create a text search query for updates, to be passed to query_updates_paginated/2.
  """
  def text_search(search_terms, queryable \\ Update) do
    if !is_nil(search_terms) and String.length(search_terms) > 0 do
      Utils.text_search(search_terms, queryable)
    else
      queryable
    end
  end

  @doc """
  Query the updates, paginated. Preloads user, media, and media_version.
  """
  def query_updates_paginated(query \\ Update, opts \\ []) do
    applied_options = Keyword.merge([cursor_fields: [{:inserted_at, :desc}], limit: 50], opts)

    query |> preload_fields() |> order_by(desc: :inserted_at) |> Repo.paginate(applied_options)
  end

  @doc """
  Gets a single update. Preloads user, media, and media_version.

  Raises `Ecto.NoResultsError` if the Update does not exist.

  ## Examples

      iex> get_update!(123)
      %Update{}

      iex> get_update!(456)
      ** (Ecto.NoResultsError)

  """
  def get_update!(id), do: Repo.get!(Update |> preload_fields(), id)

  @doc """
  Insert the given Update changeset. Helpful to use in conjunction with the dynamic changeset
  generation functions (e.g., `change_from_attribute_changeset`). Will also generate notifications.
  """
  def create_update_from_changeset(%Ecto.Changeset{data: %Update{} = _} = changeset) do
    res = changeset |> Repo.insert()

    case res do
      {:ok, update} ->
        Platform.Notifications.create_notifications_from_update(update)
        Material.broadcast_media_updated(update.media_id)

      _ ->
        nil
    end

    res
  end

  @doc """
  Update the given update using the changeset.
  """
  def update_update_from_changeset(%Ecto.Changeset{data: %Update{} = _} = changeset) do
    changeset |> Repo.update()
  end

  @doc """
  Deletes a update.

  ## Examples

      iex> delete_update(update)
      {:ok, %Update{}}

      iex> delete_update(update)
      {:error, %Ecto.Changeset{}}

  """
  def delete_update(%Update{} = update) do
    Repo.delete(update)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking update changes.

  ## Examples

      iex> change_update(update)
      %Ecto.Changeset{data: %Update{}}

  """
  def change_update(%Update{} = update, %Media{} = media, %User{} = user, attrs \\ %{}) do
    Update.changeset(update, attrs, user, media)
  end

  @doc """
  Helper API function that takes attributes change information and uses it to create an Update changeset. Requires 'explanation' to be in attrs. The change is recorded as belonging to the head of `attributes`; all other attributes should be children of the first element.
  """
  def change_from_attributes_changeset(
        %Media{} = media,
        attributes,
        %User{} = user,
        changeset,
        attrs \\ %{}
      ) do
    # We add the _combined field so that it's unambiguous when a dict represents a collection of schema fields changing
    old_value =
      attributes
      |> Enum.map(&{&1.schema_field, Map.get(media, &1.schema_field)})
      |> Map.new()
      |> Map.put("_combined", true)
      |> Jason.encode!()

    new_value =
      attributes
      |> Enum.map(
        &{&1.schema_field,
         Map.get(changeset.changes, &1.schema_field, Map.get(media, &1.schema_field))}
      )
      |> Map.new()
      |> Map.put("_combined", true)
      |> Jason.encode!()

    change_update(
      %Update{},
      media,
      user,
      attrs
      |> Map.put("old_value", old_value)
      |> Map.put("new_value", new_value)
      |> Map.put("modified_attribute", hd(attributes).name)
      |> Map.put("type", :update_attribute)
    )
  end

  @doc """
  Helper API function that takes comment information and uses it to create an Update changeset. Requires 'explanation' to be in attrs.
  """
  def change_from_comment(%Media{} = media, %User{} = user, attrs \\ %{}) do
    change_update(
      %Update{},
      media,
      user,
      attrs
      |> Map.put("type", :comment)
    )
  end

  @doc """
  Helper API function that takes attribute change information and uses it to create an Update changeset. Requires 'explanation' to be in attrs.
  """
  def change_from_media_creation(%Media{} = media, %User{} = user) do
    change_update(
      %Update{},
      media,
      user,
      %{
        "type" => :create
      }
    )
  end

  @doc """
  Helper API function that takes attribute change information and uses it to create an Update changeset. Requires 'explanation' to be in attrs.
  """
  def change_from_media_version_upload(
        %Media{} = media,
        %User{} = user,
        %MediaVersion{} = version
      ) do
    change_update(
      %Update{},
      media,
      user,
      %{
        "type" => :upload_version,
        "media_version_id" => version.id
      }
    )
  end

  @doc """
  Get the non-hidden updates associated with the given media.
  """
  def get_updates_for_media(media, exclude_hidden \\ false) do
    query =
      from u in Update,
        where: u.media_id == ^media.id,
        preload: [:user, :media, :media_version],
        order_by: [asc: u.inserted_at]

    Repo.all(if exclude_hidden, do: query |> where([u], not u.hidden), else: query)
  end

  @doc """
  Get the updates associated with the given user.

  Options:
  - limit: maximum number of updates to return
  - exclude_hidden: whether to exclude updates marked as hidden
  """
  def get_updates_by_user(user, opts) do
    query =
      from u in Update,
        where: u.user_id == ^user.id,
        preload: [:user, :media, :media_version],
        order_by: [desc: u.inserted_at],
        limit: ^Keyword.get(opts, :limit, nil)

    Repo.all(
      if Keyword.get(opts, :exclude_hidden, false),
        do: query |> where([u], not u.hidden),
        else: query
    )
  end

  @doc """
  Change the visibility (per the `hidden` field) of the given media.
  """
  def change_update_visibility(%Update{} = update, hidden) do
    Update.raw_changeset(update, %{hidden: hidden})
  end

  @doc """
  Is the given user able to view the given update?
  """
  def can_user_view(%Update{} = update, %User{} = user) do
    case Platform.Accounts.is_admin(user) do
      true ->
        true

      false ->
        case update.hidden do
          true -> false
          false -> Media.can_user_view(update.media, user)
        end
    end
  end
end
