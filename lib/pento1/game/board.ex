defmodule Pento1.Game.Board do
  alias Pento1.Game.{Pentomino, Shape}

  defstruct [
    active_pento: nil,
    completed_pentos: [],
    palette: [],
    points: []
  ]

  def puzzles(), do: ~w[default wid widest medium tiny]a  # atom list 생성

  def new(palette, points) do
    %__MODULE__{palette: palette(palette), points: points}
  end

  def new(:tiny), do: new(:small, rect(5, 3))
  def new(:widest), do: new(:all , rect(20, 3))
  def new(:wide), do: new(:all , rect(15, 4))
  def new(:medium), do: new(:all , rect(12, 5))
  def new(:default), do: new(:all , rect(10, 6))

  def to_shape(board) do
    Shape.__struct__(color: :purple, name: :board, points: board.points)
  end

  # boad 를 생성하고 해당 board 는 게임 내 다른 조각들로 채워져야 하며,
  # 채워진 상태를 계속 udpate 하면서 화면 뒤 layer에서 계속 rendering 되어야 함.
  def to_shapes(board) do
    board_shape = to_shape(board) # 게임 내 다른 조각들 처럼 생성

    pento_shapes =
      [board.active_pento | board.completed_pentos] # 활성화된 요소가 리스트 앞에
      |> Enum.reverse() # rendering 을 list 순서대로 할 경우, 뒷 요소가 가장 마지막에 화면에 덮어쓰기 되므로 순서를 역순으로 재정렬 해야
      |> Enum.filter(& &1) # 활성화 조각 중 nil 값을 가진 것은 해당 요소에서 탈락 시킴
      |> Enum.map(&Pentomino.to_shape/1) # 해당 결과를 하나의 조각으로 변환함.(?)

      [board_shape | pento_shapes]
  end

  def active?(board, shape_name) when is_binary(shape_name) do
    active?(board, String.to_existing_atom(shape_name))
  end
  def active?(%{active_pento: %{name: shape_name}}, shape_name), do: true
  def active?(_board, _shape_name), do: false

  defp rect(x, y) do
    for x <- 1..x, y <- 1..y, do: {x, y}
  end

  defp palette(:all), do: [:i, :l, :y, :n, :p, :w, :u, :v, :s, :f, :x, :t]
  defp palette(:small), do: [:u, :v, :p]
end
