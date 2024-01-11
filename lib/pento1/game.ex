defmodule Pento1.Game do
  alias Pento1.Game.{Board, Pentomino}

  @messages %{
    out_of_bounds: "Out of bounds!",
    illergal_drop: "Oops! You can't drop out of bounds or on another piece."
  }

  # -- `maybe_` 함수: 실패 가능성이 있는 함수? 동작의 허용 여부에 따라 {:ok, } / {:error, } 반환 --

  # pento 가 아직 활성화 되어있지 않은 상태
  def maybe_move(%{active_pento: p}=board, _m) when is_nil(p) do
    {:ok, board}
  end

  def maybe_move(board, move) do
    new_pento = move_fn(move).(board.active_pento)
    new_board = %{board|active_pento: new_pento} # 움직인 position 값을 update

    if Board.legal_move?(new_board),
      do: {:ok, new_board},
    else: {:error, @messages.out_of_bounds}
  end

  defp move_fn(move) do
    case move do
      :up -> &Pentomino.up/1
      :down -> &Pentomino.down/1
      :left -> &Pentomino.left/1
      :right -> &Pentomino.right/1
      :flip -> &Pentomino.flip/1
      :rotate -> &Pentomino.rotate/1
    end
  end

  def maybe_drop(board) do
    if Board.legal_drop?(board),
      do: {:ok, Board.drop(board)},
    else: {:error, @messages.illergal_drop}
  end
end
