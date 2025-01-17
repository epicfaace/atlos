defmodule Platform.Security.SecurityMode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "security_modes" do
    field :description, :string
    field :mode, Ecto.Enum, values: [:normal, :read_only, :no_access], default: :normal

    belongs_to :user, Platform.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(security_mode, attrs) do
    security_mode
    |> cast(attrs, [:description, :mode, :user_id])
    |> validate_required([:mode, :user_id])
  end
end
