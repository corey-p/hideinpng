defmodule HideInPng do
  @moduledoc """
    ## Description
    HideInPng is an Elixir module for hiding files within 
    PNG images.

    ## Examples
    iex(2)> c "hideinpng.ex"
    [HideInPng]
    iex(3)> HideInPng.encode("imgs/dice.png", "imgs/mushroom.png")
    :ok
    iex(4)> HideInPng.decode("imgs/dice.png", "imgs/decoded.png") 
    :ok

    ## Author
    Corey Phillips
    github.com/corey-p
  """
  def encode(target_path, payload_path) do
    # Open target and payload files
    {:ok, target_file} = File.open(target_path, [:read, :write])
    {:ok, payload_file} = File.open(payload_path, [:read])

    start(target_file, payload_file, "encode")
  end

  def decode(target_path, destination_path) do
    # Open target and destination files
    {:ok, target_file} = File.open(target_path, [:read])
    {:ok, destination_file} = File.open(destination_path, [:write])

    start(target_file, destination_file, "decode")
  end

  defp start(target, payload, mode) do
    # Parse out the IHDR chunk
    <<
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      length :: size(32),
      "IHDR",
      _width :: size(32),
      _height :: size(32),
      _bit_depth,
      _color_type,
      _compression_method,
      _filter_method,
      _interlace_method,
      _crc :: size(32),
      chunks :: binary
    >> = IO.binread(target, :all)

    # Recursively iterate over remaining chunks
    read_chunks(target, payload, chunks, mode, length)
    File.close(target)
    File.close(payload)
  end

  defp read_chunks(_ ,_ ,<<>>, _, _), do: 1
  defp read_chunks(target, payload, <<
                  length :: size(32),
                  chunk_type :: binary - size(4),
                  chunk_data :: binary - size(length),
                  _crc :: size(32),
                  chunks :: binary
                  >>, mode, acc) do
    cond do
      mode == "encode" and chunk_type == "IEND" ->
        inject_payload(target, payload, acc)
      mode == "decode" and chunk_type == "PAYL" ->
        IO.binwrite(payload, chunk_data)
      true -> read_chunks(target, payload, chunks, mode, acc + length)
    end
  end

  defp inject_payload(target, payload, position) do
    # Read target to position
    IO.binread(target, position)

    # Build binary to inject
    payload_binary = IO.binread(payload, :all)
    package_binary = <<byte_size(payload_binary) :: size(32)>> <> "PAYL" <> payload_binary <> "FCRC"

    # Write to target
    IO.binwrite(target, package_binary)

    # Write the end chunk
    end_chunk_binary = <<0 :: size(32)>> <> "IEND"
    IO.binwrite(target, end_chunk_binary)
  end
end
