defmodule Pento1Web.GameLive do
  use Pento1Web, :live_view

  import Pento1Web.GameLive.Component

  def mount(_params, _session, socket), do: {:ok, socket}

  def render(assigns) do
    ~H"""
      <section class="container">
        <h1 class="font-heavy text-3xl">Welcome to Pento!</h1>
        <.palette shape_names={[:i, :l, :y, :n, :p, :w, :u, :v, :s, :f, :x, :t]}/>
        <%!-- <.canvas view_box="0 0 220 70">
          <.shape
            points={ [{3, 2}, {4, 3}, {3, 3}, {4, 2}, {3, 4}] }
            fill="orange"
            name="p"
          />
        </.canvas>
        --%>
      </section>

      <%!-- ch_12_1
      <section class="container">
        <h1 class="font-heavy text-3xl">Welcome to Pento!</h1>
        <.canvas view_box="0 0 200 50">
          <.point x={0} y={0} fill="blue" name="a" />
          <.point x={5} y={0} fill="green" name="b" />
          <.point x={0} y={1} fill="red" name="c" />
          <.point x={1} y={2} fill="black" name="d" />
        </.canvas>
      </section>
      --%>

      <%!-- ch_11
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
