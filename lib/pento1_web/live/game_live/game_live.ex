defmodule Pento1Web.GameLive do
  use Pento1Web, :live_view

  import Pento1Web.GameLive.Component

  def mount(_params, _session, socket), do: {:ok, socket}

  def render(assigns) do
    ~H"""
      <section class="container">
        <h1 class="font-heavy text-3xl">Welcome to Pento!</h1>
        <%!-- viewBox 지정 범위 내에서 rect 을 그림 --%>
        <.canvas view_box="0 0 200 50">
          <%!-- import 된 point component 의 값들을 설정 --%>
          <.point x={0} y={0} fill="blue" name="a" />
          <.point x={5} y={0} fill="green" name="b" />
          <.point x={0} y={1} fill="red" name="c" />
          <.point x={1} y={2} fill="black" name="d" />
        </.canvas>
      </section>


      <%!-- 해당 reuseable component 는 Component module 로 대체됨
      <svg viewBox="0 0 100 100">
        <defs>
          <rect id="point" width="10" height="10" />
        </defs>
        <use xlink:href="#point" x="0" y="0" fill="blue" />
        <use xlink:href="#point" x="10" y="0" fill="green" />
        <use xlink:href="#point" x="0" y="10" fill="red" />
        <use xlink:href="#point" x="10" y="5" fill="black" />
      </svg> --%>

    """

  end
end
