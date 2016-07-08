# HideInPng
HideInPng is an Elixir module for encoding files within a PNG image without compromising the image or the payload.

When &HideInPng.encode/2 is run, the payload binary will be injected into the PNG as its own "PAYL" chunk just before the "IEND" chunk.

When &HideInPng.decode/2 is run, the code will look for the "PAYL" chunk and write the contents of the chunk to a file.

Inspired by:
* http://blog.brian.jp/python/png/2016/07/07/file-fun-with-pyhon.html
* http://www.zohaib.me/binary-pattern-matching-in-elixir/