# HideInPng
HideInPng is an Elixir module for encoding files within a PNG image without compromising the image or the payload.

When &HideInPng.encode/2 is run, the payload binary will be injected into the PNG as its own "PAYL" chunk just before the "IEND" chunk.

When &HideInPng.decode/2 is run, the code will look for the "PAYL" chunk and write the contents of the chunk to a file.