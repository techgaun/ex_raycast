defmodule ExRaycast do
  @moduledoc """
  A simple implementation of [Raycast algorithm](https://en.wikipedia.org/wiki/Point_in_polygon#Ray_casting_algorithm) in Elixir

  `ExRaycast` is the implementation of ray casting algorithm to determine if a point is in the polygon or not. It also includes a simple
  implementation that can be used for the cases where there's a hole in the polygon.

  This was used to test [westar kml](https://github.com/techgaun/westar_service_territory) using Elixir and is not perfect.
  """

  @doc """
  Checks if a point is inside a polygon or not

  ## Example

      iex> ExRaycast.point_in_polygon?(1, 1, [{0, 0}, {0, 2}, {2, 2}, {2, 0}])
      true

      iex> ExRaycast.point_in_polygon?(1, 3, [{0, 0}, {0, 2}, {2, 2}, {2, 0}])
      false
  """
  @spec point_in_polygon?(number, number, list) :: boolean
  def point_in_polygon?(x_point, y_point, polygons) do
    start_point = length(polygons) - 1
    {inside, _} = polygons
      |> Enum.with_index
      |> Enum.reduce({false, start_point}, fn {{xi, yi}, idx}, {inside, itr_point} ->
        {xj, yj} = Enum.at(polygons, itr_point)
        intersect = ((yi > y_point) != (yj > y_point)) && (x_point < (xj - xi) * (y_point - yi) / (yj - yi) + xi)
        inside = if intersect, do: not inside, else: inside
        {inside, idx}
      end)
    inside
  end

  @doc """
  Checks if a given lat, lng is in the polygons in a KML file or not

  ## Examples

      iex> ExRaycast.lat_long_in_kml?(37.6646855, -97.2477088, "test/support/westar.kml")
      true

      iex> ExRaycast.lat_long_in_kml?(32.6646855, -95.2477088, "test/support/westar.kml")
      false
  """
  @spec lat_long_in_kml?(number, number, String.t) :: boolean
  def lat_long_in_kml?(lat, lng, kml_file) do
    kml_file
    |> extract_geometry_from_kml
    |> process_geometry_from_kml
    |> Enum.any?(&(lat_long_in_kml_polygon?(lat, lng, &1)))
  end

  @doc """
  Checks if a given lat,long is in kml polygon or not
  """
  @spec lat_long_in_kml_polygon?(number, number, tuple) :: boolean
  def lat_long_in_kml_polygon?(lat, lng, {out_points, in_points}) when length(out_points) > 0 and length(in_points) > 0 do
    point_in_polygon?(lat, lng, out_points) and (not point_in_polygon?(lat, lng, in_points))
  end
  def lat_long_in_kml_polygon?(lat, lng, {out_points, in_points}) when length(out_points) > 0 and length(in_points) === 0 do
    point_in_polygon?(lat, lng, out_points)
  end
  def lat_long_in_kml_polygon?(_lat, _lng, {_out_points, _in_points}), do: false

  defp extract_geometry_from_kml(file) do
    File.read!(file)
    |> Floki.find("multigeometry")
    |> Floki.raw_html
  end

  defp process_geometry_from_kml(geometry) do
    geometry
    |> Floki.find("polygon")
    |> Stream.map(fn x ->
      out_search = x
        |> Floki.find("outerboundaryis")

      out_points = case out_search do
        [{"outerboundaryis", [], [{"linearring", [], [{"coordinates", [], coords}]}]}] ->
          coords
          |> parse_kml_coords

        _ ->
          []
      end

      in_search = x
        |> Floki.find("innerboundaryis")

      in_points = case in_search do
        [{"innerboundaryis", [], [{"linearring", [], [{"coordinates", [], coords}]}]}] ->
          coords
          |> parse_kml_coords

        _ ->
          []
      end
      {out_points, in_points}
    end)
    |> Enum.filter(fn {out_points, in_points} ->
      length(out_points) > 0 or length(in_points) > 0
    end)
  end

  defp parse_kml_coords([coords]), do: parse_kml_coords(coords)
  defp parse_kml_coords(coords) when is_bitstring(coords) do
    coords
    |> String.split(" ")
    |> Enum.map(fn x ->
      [lng | [lat | _]] = x
        |> String.split(",")

      {float(lat), float(lng)}
    end)
  end
  defp parse_kml_coords(_), do: []

  defp float(val) when is_bitstring(val) do
    {v, _} = Float.parse(val)
    v
  end
  defp float(v), do: v
end
