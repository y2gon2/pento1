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
  defp palette(:medium), do: [:t, :y, :l, :p, :n, :v, :u]

  # 1. 아직 조각이 없는 board 칸을 클릭했을 때 -> 반응 X
  def pick(board, :board), do: board

  # 2. 이미 활성화된 조각을 다시 클릭 할 때 -> 비활성화 & `:active_pento` 값을 nil 로 변경해서
  #    다른 조각을 활성화 할 수 있도록 함.
  #    다만 건드린 조각이 현재 활성화 조각이 아닌 경우, 아무런 반응이 일어나지 않아야 함.
  def pick(%{active_pento: pento}=board, sname) when not is_nil(pento) do
    if pento.name == sname do
      %{board | active_pento: nil}
    else
      board
    end
  end

  # 3. 현재 활성화된 조각이 없으며, 클릭한 조각이 아직 board.complited_pentos 에 있는지 확인
  #    -> 있다면, 기존에 놓여진 조각 중 선택된 조각을 활성화
  #    -> 없다면, 클릭한 새 조각을 활성화 조각에 포함 시킴.
  def pick(board, shape_name) do
    active =
      board.complited_pentos
      |> Enum.find(&(&1.name == shape_name))     # Enum.find의 결과가 nil이 아닐 경우, 해당 결과를 그대로 사용
      |> Kernel.||(new_pento(board, shape_name)) # Enum.find의 결과가 nil일 경우, new_pento(board, shape_name)를 호출하고 그 결과를 사용

    # 기존 조각이 선택되었다면, 해당 조각을 completed_pentos 에서는 제거해주어야 하므로 이를 filtering 아여 제거시킴.
    completed = Enum.filter(board.completed_pentos, &(&1.name != shape_name))

    # acitve_pento: / complited_pentos: value 를 새로 설정함.
    %{board| active_pento: active, completed_pentos: completed}
  end

  # 새로 선택된 조각 생성
  defp new_pento(board, shape_name) do
    Pentomino.new(name: shape_name, location: midpoints(board))
  end

  # board 화면 중에 신규로 선택된 조각이 오도록 위치값 설정
  defp midpoints(board) do
    {xs, ys} = Enum.unzip(board.points)
    {midpoints(xs), midpoints(ys)}
  end
  defp midpoint(i), do: round(Enum.max(i) / 2.0)

  # 마우스 drop ? 기능에 대한 정의 ?
  # 선택된게 없다면 drop 기능에서 아무 변화가 일어나지 않음
  # 현재 조각을 선택한 상태였다면, drop 할때 활성화된 조각을 completed_pentos 에 포함시키고
  # 활성화 속성을 비운다. (nil)
  # 다만 drop 기능이 적용되는 범위를 설정해 주어야 하는데 "legal drop checking",
  # 우선 해당 부분은 미구현함.(game boundary layer 가 필요함)
  def drop(%{active_pento: nil}=board), do: board
  def drop(%{active_pento: pento}=board) do
    board
    |> Map.put(:active_pento, nil)
    |> Map.put(:completed_pentos, [pento|board.completed_pentos])
  end

  # drag ? 는 게임 영역 (point) 내에서만 가능함을 확인
  def legal_move?(%{active_pento: pento, points: points}=_board) do
    pento.location in points
  end

  # 현재 활성화 조각이 없다면 화면 어디서든 drop 해도 상관없이 어떤 반응이 일어나지 않음.
  # 활성화된 조각이 있는 상태에서 drop 이 발생하면,
  def legal_drop?(%{active_pento: pento}) when is_nil(pento), do: false
  def legal_drop?(%{active_pento: pento, points: board_points}=board) do
    #  1. 그 조각의 point 들이 board boundary 내 모두 존재하는지 확인
    points_on_board =
      Pentomino.to_shape(pento).points
      |> Enum.all?(fn point -> point in board_points end)

    #  2. 그 조각의 point 들이 기존의 놓여진 다른 조각과 겹치지 않는지 확인
    no_overlapping_pentos =
      !Enum.any?(board.completed_pentos, &Pentomino.overlapping?(pento, &1))

    # 두 조건 모두 true 이어야 drop 가능임을 반환
    points_on_board and no_overlapping_pentos
  end
end
