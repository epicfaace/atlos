defmodule Platform.UpdatesTest do
  use Platform.DataCase

  alias Platform.Material
  alias Platform.Updates

  import Platform.MaterialFixtures
  import Platform.AccountsFixtures

  describe "updates" do
    test "Material.update_media_attribute_audited creates an update" do
      media = media_fixture()
      admin = admin_user_fixture()

      assert Enum.empty?(Updates.get_updates_for_media(media))

      assert {:ok, _} =
               Material.update_media_attribute_audited(
                 media,
                 Material.Attribute.get_attribute(:restrictions),
                 admin,
                 %{
                   "explanation" => "Very important explanation",
                   "attr_restrictions" => ["Frozen"]
                 }
               )

      updates = Updates.get_updates_for_media(media)
      assert length(updates) == 1

      assert hd(updates).user_id == admin.id
      assert hd(updates).media_id == media.id
      assert hd(updates).hidden == false
    end

    test "change_update_visibility/2 changes visibility" do
      media = media_fixture()
      admin = admin_user_fixture()

      assert Enum.empty?(Updates.get_updates_for_media(media))

      assert {:ok, _} =
               Material.update_media_attribute_audited(
                 media,
                 Material.Attribute.get_attribute(:restrictions),
                 admin,
                 %{
                   "explanation" => "Very important explanation",
                   "attr_restrictions" => ["Frozen"]
                 }
               )

      assert {:ok, _} =
               Updates.change_from_comment(media, admin, %{
                 "explanation" => "This is my comment."
               })
               |> Updates.create_update_from_changeset()

      updates = Updates.get_updates_for_media(media)

      assert length(updates) == 2

      assert {:ok, _} =
               Updates.change_update_visibility(hd(updates), true)
               |> Updates.update_update_from_changeset()

      modified_updates = Updates.get_updates_for_media(media)
      assert length(modified_updates) == 2
      assert Enum.any?(Enum.map(modified_updates, & &1.hidden))
    end

    test "can_user_view/2 works for admins" do
      media = media_fixture()
      admin = admin_user_fixture()
      user = user_fixture()

      assert {:ok, _} =
               Material.update_media_attribute_audited(
                 media,
                 Material.Attribute.get_attribute(:restrictions),
                 admin,
                 %{
                   "explanation" => "Very important explanation",
                   "attr_restrictions" => ["Frozen"]
                 }
               )

      updates = Updates.get_updates_for_media(media)
      assert length(updates) == 1

      assert length(Enum.filter(updates, &Updates.can_user_view(&1, user))) == 1
      assert length(Enum.filter(updates, &Updates.can_user_view(&1, admin))) == 1

      assert {:ok, _} =
               Updates.change_update_visibility(hd(updates), true)
               |> Updates.update_update_from_changeset()

      modified_updates = Updates.get_updates_for_media(media)
      assert length(modified_updates) == 1
      assert Enum.any?(Enum.map(modified_updates, & &1.hidden))

      assert Enum.empty?(Enum.filter(modified_updates, &Updates.can_user_view(&1, user)))
      assert length(Enum.filter(modified_updates, &Updates.can_user_view(&1, admin))) == 1

      # Quick check to also verify get_updates_for_media excludes hidden
      assert Enum.empty?(Updates.get_updates_for_media(media, true))
    end
  end
end
