defmodule Pento1.Game.Pentomino do
  alias Pento1.Game.Shape
  alias Pento1.Game.Point

  @names [:i, :l, :y, :n, :p, :w, :u, :v, :s, :f, :x, :t]
  @default_location {8, 8}

  defstruct [
    name: :i,
    rotation: 0,
    reflected: false,
    location: @default_location
  ]

  def new(field \\ []), do: __struct__(field)

  # ------ 게임에서 player input 에 의한 동작 -----

  def rotate(%{rotation: degrees} = p) do
    %{p | rotation: rem(degrees + 90, 360)}
  end

  def flip(%{reflected: reflected} = p) do
    %{p | reflected: not reflected}
  end

  def up(p) do
    %{p | location: Point.move(p.location, {0, -1})}
  end

  def down(p) do
    %{p | location: Point.move(p.location, {0, -1})}
  end

  def left(p) do
    %{p | location: Point.move(p.location, {-1, 0})}
  end

  def right(p) do
    %{p | location: Point.move(p.location, {1, 0})}
  end

  # -------------------------------------------------

  # 플레이어가 새로운 조각을 놓았을 때 (drop), 기존에 놓여져 있는 조각과 겹치지 않는지 확인
  def overlapping?(pento1, pento2) do
    {p1, p2} = {to_shape(pento1).points, to_shape(pento2).points}
    Enum.count(p1 -- p2) != 5
    # "--" 두번째 list 원소가 첫번째 list 원소에 있으면 이를 제거한  첫번째 list
    # 모든 조각은 5개 point 로 되어있으므로 p1 조각 point 값들이 p2 조각 point 값들과 전혀 겹
  end

  def to_shape(pento) do
    Shape.new(pento.name, pento.rotation, pento.reflected, pento.location)
  end

end
