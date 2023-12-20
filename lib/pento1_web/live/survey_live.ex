defmodule Pento1Web.SurveyLive do
  use Pento1Web, :live_view

  alias Pento1Web.SurveyLive.Component
  alias Pento1.{Survey}
  alias Pento1Web.DemographicLive

  def mount(_params, _session, socket) do
    IO.inspect(socket, label: "socket : ")
    {:ok,
    socket |> assign_demographic
    }
  end

  defp assign_demographic(%{assigns: %{current_user: current_user}}=socket) do
    assign(
      socket,
      :demographic,
      Survey.get_demographic_by_user(current_user)
    )
  end
end
