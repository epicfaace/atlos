defmodule Platform.Repo.Migrations.MigrateFlagToStatus do
  use Ecto.Migration

  def change do
    rename table(:media), :attr_flag, to: :attr_status

    execute "ALTER TABLE media DROP COLUMN searchable"

    alter table(:media) do
      modify(:attr_status, :string, default: "Unclaimed")
    end

    execute """
            ALTER TABLE media
            ADD COLUMN searchable tsvector
            GENERATED ALWAYS AS (
              to_tsvector('english',
                imm_array_to_string(
                  coalesce(slug, '') || ARRAY[]::text[] ||

                  coalesce(description, '') || ARRAY[]::text[] ||
                  coalesce(attr_time_of_day, '') || ARRAY[]::text[] ||
                  coalesce(attr_environment, '') || ARRAY[]::text[] ||
                  coalesce(attr_weather, '{}') || ARRAY[]::text[] ||
                  coalesce(attr_camera_system, '') || ARRAY[]::text[] ||
                  coalesce(attr_more_info, '') || ARRAY[]::text[] ||
                  coalesce(attr_civilian_impact, '{}') || ARRAY[]::text[] ||
                  coalesce(attr_event, '{}') || ARRAY[]::text[] ||
                  coalesce(attr_casualty, '{}') || ARRAY[]::text[] ||
                  coalesce(attr_military_infrastructure, '{}') || ARRAY[]::text[] ||
                  coalesce(attr_weapon, '{}') || ARRAY[]::text[] ||
                  coalesce(attr_status, '') || ARRAY[]::text[] ||

                  coalesce(attr_sensitive, '{}') || ARRAY[]::text[] ||
                  coalesce(attr_restrictions, '{}'),
                  ' ', ''
                )
              )
            ) STORED
            """
            |> String.replace("\n", " ")
  end
end
