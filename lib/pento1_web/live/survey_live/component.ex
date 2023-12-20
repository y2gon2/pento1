#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/liveview for more book information.
#---
defmodule Pento1Web.SurveyLive.Component do
  use Phoenix.Component

  attr :content, :string, required: true
  slot :inner_block, required: true
  def hero(assigns) do
    ~H"""
    <h1 class="font-heavy text-3xl">
      <%= @content %>
    </h1>
    <h3>
      <%= render_slot(@inner_block) %>
    </h3>
    <%!-- <pre>
      <%= inspect(assigns, pretty: true) %>

      <br/>
      -------------------------------------------------

      <% %{ inner_block: [%{inner_block: block_fn}]} = assigns %>
      <%= inspect(block_fn.(assigns.__changed__, assigns), pretty: true) %>
    </pre> --%>
    """
  end
end
