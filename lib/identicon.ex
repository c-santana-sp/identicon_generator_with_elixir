defmodule Identicon do
  def main(input) do
    input
    |> hash_input()
    |> pick_color()
    |> build_grid()
    |> filter_odd_squares()
    |> build_pixels_map()
    |> draw_image()
    |> save_image(input)
  end

  defp hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Identicon.Image{hex: hex}
  end

  defp pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    # %Identicon.Image{hex: hex_list} = image
    # [r, g, b | _tail] = hex_list

    # %Identicon.Image{hex: [r, g, b | _tail]} = image
    %Identicon.Image{image | color: {r, g, b}}
  end

  defp build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3)
      |> mirror_row()
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end

  defp mirror_row(rows) do
    for [r, g, _b] = row <- rows do
      row ++ [g, r]
    end
  end

  defp filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid =
      Enum.filter(grid, fn {code, _index} ->
        rem(code, 2) == 0
      end)

    %Identicon.Image{image | grid: grid}
  end

  defp build_pixels_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map(grid, fn {_code, index} ->
        hor = rem(index, 5) * 50
        ver = div(index, 5) * 50
        top_left = {hor, ver}
        bottom_right = {hor + 50, ver + 50}
        {top_left, bottom_right}
      end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  defp draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  defp save_image(image, filename) do
    File.write("./images/#{filename}.png", image)
  end
end
