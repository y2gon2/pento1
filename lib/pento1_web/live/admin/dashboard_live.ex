defmodule Pento1Web.Admin.DashboardLive do
  alias Pento1Web.Admin.{SurveyResultsLive, UserActivityLive}
  use Pento1Web, :live_view

  alias Pento1Web.Endpoint

  @survey_results_topic "survey_results"
  @user_activity_topic "user_activity"

  # mount/3 는 2번 call 됨
  # 1. 최초 mount & HTML 응답으로 정적 rendering 시
  #    why?
  #    * 초기 페이지 로드 성능 향상: 사용자가 처음으로 LiveView 페이지를 방문할 때,
  #      WebSocket 연결이 아직 수립되지 않은 상태에서의 초기 렌더링이 발생, 이를 통해
  #      사용자는 즉각적으로 페이지 내용을 볼 수 있으며, 이는 페이지 로드 시간을 개선함.
  #      즉, 사용자가 빠르게 컨텐츠를 볼 수 있도록 하여 좋은 사용자 경험을 제공함.
  #
  #    * 점진적 향상(Progressive Enhancement): 이 초기 렌더링은 JavaScript 또는 WebSocket
  #      연결 없이도 기본적인 페이지 기능을 제공함. 이는 사용자의 브라우저가 WebSocket을
  #      지원하지 않거나 JavaScript가 비활성화된 경우에도 페이지의 기본적인 정보와 기능을
  #      사용할 수 있게 해줌.
  #
  #    * 실시간 연결 준비: WebSocket 연결이 수립되면, LiveView는 이미 렌더링된 정적 HTML을
  #      '업그레이드'하여 실시간 기능을 활성화함. 이 과정은 사용자에게 눈에 띄지 않으며,
  #      페이지 내용을 다시 로드할 필요 없이 실시간 기능이 작동하기 시작함.
  #
  #    * SEO (search engine optimization) 및 접근성 고려: 검색 엔진은 JavaScript를 실행하지
  #      않거나 제한적으로 실행하는 경우가 많음. 정적 HTML을 먼저 렌더링함으로써, 검색 엔진이
  #      페이지의 내용을 인덱싱할 수 있도록 함. 또한, 다양한 접근성 요구 사항을 가진 사용자들에게도
  #      기본적인 페이지 접근성을 제공.
  #
  # 2. WebSocket-connected live view process 시작 시
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(@survey_results_topic)
      # 첫 번째 호출(정적 HTML 렌더링)에서는 실시간 통신이 필요 없으므로 구독을 하지 않음.

      Endpoint.subscribe(@user_activity_topic)
    end

    {:ok,
    socket
    |> assign(:survey_results_component_id ,"survey-results")
    |> assign(:user_activity_component_id, "user-activity")
    }
  end

  # dashboard rendering 은 자식 compoenent 에서 구현되어 있지만 자식 compoenent 는
  # handle_info/2 를 수행할 수 없기 때문에 (부모 process 내에서 실행되기 때문에)
  # 즉, 외부 message 가 받아 졌을 때, `send_update/2` 로 어떤 Live Component 가
  # re-rendering 시킬지를 명시하는 함수.
  def handle_info(%{event: "rating_created"}, socket) do
    send_update(
      SurveyResultsLive,
      id: socket.assigns.survey_results_component_id
    )

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    send_update(
      UserActivityLive,
      id: socket.assigns.user_activity_component_id
    )

    {:noreply, socket}
  end
end

# defmodule Pento1Web.Admin.DashboardLive do
#   use Pento1Web, :live_view
#   alias Pento1Web.Admin.{SurveyResultsLive, UserActivityLive}
#   alias Pento1Web.Endpoint
#   @survey_results_topic "survey_results"
#   @user_activity_topic "user_activity"

#   def mount(_params, _session, socket) do
#     if connected?(socket) do
#       Endpoint.subscribe(@survey_results_topic)
#       Endpoint.subscribe(@user_activity_topic)
#     end

#     {:ok,
#      socket
#      |> assign(:survey_results_component_id, "survey-results")
#      |> assign(:user_activity_component_id, "user-activity")}
#   end

#   def handle_info(%{event: "rating_created"}, socket) do
#     send_update(
#       SurveyResultsLive,
#       id: socket.assigns.survey_results_component_id)
#     {:noreply, socket}
#   end

#   def handle_info(%{event: "presence_diff"}, socket) do
#     send_update(
#       UserActivityLive,
#       id: socket.assigns.user_activity_component_id)
#     {:noreply, socket}
#   end
# end
