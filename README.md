# ExRaycast

> A simple raycast algorithm implementation in Elixir

`ExRaycast` is the implementation of ray casting algorithm to determine if a point is in the polygon or not. It also includes a simple
implementation that can be used for the cases where there's a hole in the polygon.

This was used to test [westar kml](https://github.com/techgaun/westar_service_territory) using Elixir and is not perfect.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `ex_raycast` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ex_raycast, "~> 0.1.0"}]
    end
    ```

  2. Ensure `ex_raycast` is started before your application:

    ```elixir
    def application do
      [applications: [:ex_raycast]]
    end
    ```
