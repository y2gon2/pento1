defmodule Pento1Web.Admin.DashboardLive do
  use Pento1Web, :live_view

  def mount(_params, _session, socket) do
    {:ok,
    socket
    |> assign(:survey_results_component_id ,"survey-results")
    }
  end

end
