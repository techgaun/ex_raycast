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
end
