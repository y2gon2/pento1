defmodule Pento1Web.GameLive do
  use Pento1Web, :live_view

  import Pento1Web.GameLive.Component
  alias Pento1Web.GameLive.Board


  def mount(%{"puzzle" => puzzle}, _session, socket) do
    {:ok, assign(socket, puzzle: puzzle)}
  end

  def render(assigns) do
    ~H"""
      <section class="container">
        <div class = "gird gird-cols-2">
          <div>
            <h1 class="font-heavy text-3xl">Welcome to Pento!</h1>
          </div>
          <.help />
        </div>
        <.live_component module={Board} puzzle={@puzzle} id="game" />

        <%!-- <.palette shape_names={[:i, :l, :y, :n, :p, :w, :u, :v, :s, :f, :x, :t]}/> --%>


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

  def help(assigns) do
    ~H"""
    <div>
      <.help_button />
      <.help_page />
    </div>
    """
  end

  attr :class, :string, default: "h-8 w-8 text-slate hover:text-slate-400"
  def help_button(assigns) do
    ~H"""
    <button phx-click={JS.toggle(to: "#info")}>
      <.icon name="hero-question-mark-circle-solid" mini class={@class} />
    </button>
    """
  end

  def help_page(assigns) do
    ~H"""
    <div id="info" hidden class="fixed hidden bg-white mx-4 border border-2">
      <ul class="mx-8 list-disc">
      <li>Click on a pento to pick it up</li>
        <li>Drop a pento with a space</li>
        <li>Pentos can't overlap</li>
        <li>Pentos must be fully on the board</li>
        <li>Rotate a pento with shift</li>
        <li>Flip a pento with enter</li>
        <li>Place all the pentos to win</li>
      </ul>
    </div>
    """
  end
end
