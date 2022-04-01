defmodule Platform.Repo.Migrations.CreateUpdates do
  use Ecto.Migration

  def change do
    create table(:updates) do
      add :explanation, :text
      add :old_value, :text
      add :new_value, :text
      add :modified_attribute, :string
      add :media_id, references(:media, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:updates, [:media_id])
    create index(:updates, [:user_id])
  end
end
