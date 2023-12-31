defmodule Pento1Web.GameLive.Component do
  use Phoenix.Component
  alias Pento1.Game.Pentomino
  import Pento1Web.GameLive.Colors

  @width 10

  attr :x, :integer, required: true
  attr :y, :integer, required: true
  attr :fill, :string
  attr :name, :string
  attr :"phx-click", :string
  attr :"phx-value", :string
  attr :"phx-target", :any
  def point(assigns) do
    ~H"""
      <use xlink:href="#point"
        x={ convert(@x) }
        y={ convert(@y) }
        fill={ @fill }
        phx-click="pick"
        phx-value-name={ @name }
        phx-target="#game"
      />
    """
  end

  # pentomino 값(?) 은 1 부터 시작하지만, canvas 는 0 부터 시작하므로
  # `i - 1` 로 보정 & center 값(?) 으로 보정?
  defp convert(i) do
    (i-1) * @width + 2 * @width
  end

  # slot 사용에 대해.
  # canvas 컴포넌트 사용시, SVG 내부에 렌더링하고 싶은 내용을 정의할 공간을 제공
  # slot은 컴포넌트의 내부 콘텐츠를 동적으로 변경하고자 할 때 유용함.
  # 예를 들어, 정적인 내용만을 표시하는 컴포넌트나, 어떠한 사용자 입력도 받지 않는
  # 단순한 UI 요소는 slot 없이 구현가능. (SVG rendering 도 정적인 경우 slot 필요 없음.)
  attr :view_box, :string
  slot :inner_block, required: true
  def canvas(assigns) do
    ~H"""
    <svg viewBox={ @view_box }>
      <defs>
        <%!-- 위에 정의된 point component 사용하여 정사각형 생성 --%>
        <rect id="point" width="10" height="10" />
      </defs>
      <%= render_slot(@inner_block) %>
    </svg>
    """
  end

  # 퍼즐 조각의 형태, 색 의 값을 받아 rendering
  attr :points, :list, required: true
  attr :name, :string, required: true
  attr :fill, :string, required: true
  def shape(assigns) do
    ~H"""
    <%= for {x, y} <- @points do %>
      <.point x={x} y={y} fill={@fill} name={@name} />
    <% end %>
    """
  end

  attr :shape_names, :list, required: true
  attr :completed_shape_names, :list, default: []
  def palette(assigns) do
    ~H"""
    <div id="palette">
      <.canvas view_box="0 0 500 125">
        <%= for shape <- palette_shapes(@shape_names) do %>
          <.shape
            points={ shape.points }
            fill={ color(shape.color, false, shape.name in @completed_shape_names) }
            name={ shape.name }
          />
        <% end %>
      </.canvas>
    </div>
    """
  end

# --- 모든 모양의 조각을 2 * 6 배열로 배치하기 위한 내부 함수들 ---
  defp palette_shapes(names) do
    names
    |> Enum.with_index()
    |> Enum.map(&place_pento/1)
  end

  defp place_pento({name, i}) do
    Pentomino.new(name: name, location: location(i))
    |> Pentomino.to_shape()
  end

  defp location(i) do
    x = rem(i, 6) * 4 + 3
    y = div(i, 6) * 5 + 3
    {x, y}
  end
  # -----------------------------------------------------------
end
