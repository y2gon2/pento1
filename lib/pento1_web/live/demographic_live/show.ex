defmodule Pento1Web.DemographicLive.Show do
  use Phoenix.Component
  use Phoenix.HTML
  alias Pento1Web.CoreComponents
  alias Pento1.Survey.Demographic

  attr :demographic, Demographic, required: true

  def details(assigns) do
    ~H"""
    <div>
      <h2 class="font-medium text-2xl">
        Demographics <%= raw "&#x2713;" %>
      </h2>
      <CoreComponents.table
        rows={[@demographic]}
        id={to_string @demographic.id}
      >
        <:col :let={demographic} label="Gender">
          <%= demographic.gender %>
        </:col>
        <:col :let={demograpic} label="Year of Birth">
          <%= demograpic.year_of_birth%>
        </:col>
      </CoreComponents.table>
    </div>
    """
  end
end
