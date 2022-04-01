defmodule Platform.Material.Media do
  use Ecto.Schema
  import Ecto.Changeset
  alias Platform.Utils
  alias Platform.Material.Attribute
  alias Platform.Updates.Update

  schema "media" do
    # Core uneditable data
    field :slug, :string, autogenerate: {Utils, :generate_media_slug, []}

    # Core editable data
    field :description, :string

    # Metadata Attributes
    field :attr_sensitive, {:array, :string}

    # "Normal" Attributes
    field :attr_time_of_day, :string

    # Virtual attributes
    field :explanation, :string, virtual: true # Used for update explanations

    # Metadata
    timestamps()
    has_many :versions, Platform.Material.MediaVersion
  end

  @doc false
  def changeset(media, attrs) do
    media
    |> cast(attrs, [:description, :attr_sensitive])
    |> validate_required([:description])

    # These are special attributes, since we define it at creation time. Eventually, it'd be nice to unify this logic with the attribute-specific editing logic.
    |> Attribute.validate_attribute(Attribute.get_attribute(:sensitive))
    |> Attribute.validate_attribute(Attribute.get_attribute(:description))
  end
end
