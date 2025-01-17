defmodule Platform.Utils do
  @moduledoc """
  Utilities for the platform.
  """
  import Ecto.Query, warn: false

  @tag_regex ~r/(\s|^)(@([A-Za-z0-9_]+))/
  @identifier_regex ~r/(\s|^)(ATL-[A-Z0-9]{6})/

  def get_tag_regex(), do: @tag_regex

  def generate_media_slug() do
    slug =
      "ATL-" <>
        for _ <- 1..6, into: "", do: <<Enum.random('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ')>>

    if !is_nil(Platform.Material.get_full_media_by_slug(slug)) do
      generate_media_slug()
    else
      slug
    end
  end

  def generate_random_sequence(length) do
    for _ <- 1..length, into: "", do: <<Enum.random('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ')>>
  end

  def generate_secure_code() do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64()
  end

  def make_keys_strings(map) do
    Enum.reduce(map, %{}, fn
      {key, value}, acc when is_atom(key) -> Map.put(acc, Atom.to_string(key), value)
      {key, value}, acc -> Map.put(acc, key, value)
    end)
  end

  def slugify(string) do
    string
    |> String.downcase()
    |> String.replace(~r/[^a-zA-Z0-9 &]/, "")
    |> String.replace("&", "and")
    |> String.split()
    |> Enum.join("-")
  end

  def truncate(str, length \\ 30) do
    if String.length(str) > length do
      "#{String.slice(str, 0, length - 3) |> String.trim()}..."
    else
      str
    end
  end

  def check_captcha(params) do
    token = Map.get(params, "h-captcha-response")

    if System.get_env("ENABLE_CAPTCHAS", "false") == "false" do
      true
    else
      if is_nil(token) or String.length(token) == 0 do
        false
      else
        {:ok, _status, _headers, body} =
          :hackney.post(
            "https://hcaptcha.com/siteverify",
            [{"Content-Type", "application/x-www-form-urlencoded"}],
            # Is this interpolation secure?
            "response=#{token}&secret=#{System.get_env("HCAPTCHA_SECRET")}",
            [:with_body]
          )

        body |> Jason.decode!() |> Map.get("success")
      end
    end
  end

  def render_markdown(markdown) do
    # Safe markdown rendering. No images or headers.

    # First, strip images and turn them into links. Primitive.
    stripped_images = Regex.replace(~r"!*\[", markdown, "[")

    # Second, link ATL identifiers.
    identifiers_linked =
      Regex.replace(@identifier_regex, stripped_images, " [\\0](/incidents/\\2)")

    # Third, turn @'s into links.
    tags_linked = Regex.replace(@tag_regex, identifiers_linked, " [\\0](/profile/\\3)")

    # Strip all tags and render markdown
    rendered = tags_linked |> HtmlSanitizeEx.strip_tags() |> Earmark.as_html!()

    # Perform another round of cleaning (images will be stripped here too)
    sanitized = rendered |> HtmlSanitizeEx.Scrubber.scrub(Platform.Security.UgcSanitizer)

    sanitized
  end

  def generate_qrcode(uri) do
    uri
    |> EQRCode.encode()
    |> EQRCode.svg(width: 264)
    |> Phoenix.HTML.raw()
  end

  def get_instance_name() do
    System.get_env("INSTANCE_NAME")
  end

  def get_instance_version() do
    System.get_env("APP_REVISION", "unknown")
  end

  def get_runtime_information() do
    region = System.get_env("FLY_REGION", "unknown")
    alloc_id = System.get_env("FLY_ALLOC_ID", "unknown")

    "allocation #{alloc_id} in region #{region}"
  end

  def text_search(search_terms, queryable, opts \\ []) do
    if Keyword.get(opts, :literal, false) do
      # Manually adding the quotes here make it possible to search for source links directly
      wrapped =
        if String.starts_with?(search_terms, "\""), do: search_terms, else: "\"#{search_terms}\""

      queryable
      |> where(
        [q],
        fragment("? @@ websearch_to_tsquery('english', ?)", q.searchable, ^wrapped)
      )
    else
      queryable
      |> where(
        [q],
        fragment("? @@ websearch_to_tsquery('english', ?)", q.searchable, ^search_terms)
      )
    end
  end
end
