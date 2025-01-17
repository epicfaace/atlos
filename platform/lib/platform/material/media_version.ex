defmodule Platform.Material.MediaVersion do
  use Ecto.Schema
  import Ecto.Changeset
  alias Platform.Accounts
  alias Platform.Material.Media
  alias __MODULE__

  @derive {Jason.Encoder, except: [:__meta__, :client_name, :file_location, :media]}
  schema "media_versions" do
    field :file_location, :string
    field :file_size, :integer
    field :mime_type, :string
    field :client_name, :string
    field :duration_seconds, :integer

    field :scoped_id, :integer
    field :upload_type, Ecto.Enum, values: [:user_provided, :direct], default: :user_provided
    field :status, Ecto.Enum, values: [:pending, :complete, :error], default: :complete
    field :source_url, :string
    field :hashes, :map, default: %{}

    field :visibility, Ecto.Enum, default: :visible, values: [:visible, :hidden, :removed]

    belongs_to :media, Media

    timestamps()
  end

  @doc false
  def changeset(media_version, attrs) do
    media_version
    |> cast(attrs, [
      :file_location,
      :file_size,
      :upload_type,
      :status,
      :duration_seconds,
      :source_url,
      :mime_type,
      :client_name,
      :media_id,
      :visibility,
      :scoped_id,
      :hashes
    ])
    |> validate_required([:source_url],
      message: "Please add a link."
    )
    |> validate_required([
      :status,
      :upload_type,
      :media_id
    ])
    |> unique_constraint([:media_id, :scoped_id], name: "media_versions_scoped_id_index")
  end

  @doc """
  Can the given user view the media version?
  """
  def can_user_view(%MediaVersion{} = version, %Accounts.User{} = user) do
    case version.visibility == :removed do
      true -> Accounts.is_privileged(user)
      false -> true
    end
  end
end
