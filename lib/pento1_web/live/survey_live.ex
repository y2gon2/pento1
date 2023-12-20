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

  # To teach the SurveyLive view how to respond to our message
  # handle_info/2는 시스템 또는 백엔드 관련 이벤트를 처리하는 반면,
  # handle_event/3는 프론트엔드 사용자 인터페이스 이벤트를 처리하는 데 사용됨.
  #
  # 해당 project 에서는 handle_event 자체는 자식 component 에서 처리되지만
  # 부모 view 내에서 assgin 정보를 받아서 update 하고, 이에 따라, 등록된 demographic 정보를
  # 보여주는 다른 자식 component 로 전환해 주어야 하므로, 이 작업을 위해 사용됨.
  def handle_info({:created_demographic, demographic}, socket) do
    {:noreply, handle_demographic_created(socket, demographic)}
  end

  def handle_demographic_created(socket, demographic) do
    socket
    |> put_flash(:info, "Demographic created successfully") # 화면에 해당 message 보여줌.
    |> assign(:demographic, demographic) # 새로 받은 demographic 정보를 assign 에 할당.
  end

  defp assign_demographic(%{assigns: %{current_user: current_user}}=socket) do
    assign(
      socket,
      :demographic,
      Survey.get_demographic_by_user(current_user)
    )
  end
end
