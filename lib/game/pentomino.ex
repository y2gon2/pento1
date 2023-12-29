defmodule Pento1.Game.Pentomino do
  @names [:i, :l, :y, :n, :p, :w, :u, :v, :s, :f, :x, :t]
  @default_location {8, 8}

  defstruct [
    name: :i,
    rotation: 0,
    reflected: false,
    location: @default_location
  ]

  def new(field \\ []), do: __struct__(field)

end
