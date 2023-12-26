defmodule Pento1Web.SurveyLive do
  use Pento1Web, :live_view

  alias Pento1Web.SurveyLive.Component
  alias Pento1.{Survey, Catalog}
  alias Pento1Web.{DemographicLive, RatingLive, Endpoint}

  @survey_results_topic "survey_results"

  def mount(_params, _session, socket) do
    IO.inspect(socket, label: "socket : ")
    {:ok,
    socket
    |> assign_demographic()
    |> assign_products()
    }
  end

  # product & rating 관련 처리 함수

  # Elixir에서 같은 이름과 인자 개수(arity)를 가진 함수 정의를 연속적으로 배치하는 것은
  # 컴파일러의 요구 사항이며, 단순한 가독성 문제 이상의 중요한 의미를 가진다.
  #
  # 1. 함수 패턴 매칭의 일관성:
  # Elixir는 함수 호출 시 패턴 매칭을 사용하여 적절한 함수 정의를 찾음.
  # 같은 이름과 arity를 가진 함수 정의들이 분산되어 있다면, 패턴 매칭 과정이
  # 예측하기 어려워질 수 있음에 따라, 연속적으로 배치함으로써, 컴파일러는 함수의
  # 모든 정의를 올바른 순서대로 확인하고, 호출 시 적절한 정의를 효율적으로 선택 가능해짐
  #
  # 2. 코드의 명확성과 유지 관리:
  # 같은 함수의 다양한 정의들이 연속적으로 나열되어 있으면, 개발자는 해당 함수의
  # 모든 동작을 더 쉽게 파악하여 유지 관리와 디버깅을 쉽게 하며, 코드의 가독성을 높임.
  #
  # 결론적으로, 이 규칙은 컴파일 시스템의 요구 사항이자 Elixir 언어의 패턴 매칭
  # 메커니즘과 관련된 중요한 부분으로 따르지 않으면, 프로그램이 예상대로 작동하지
  # 않을 수 있으며, 컴파일 오류가 발생할 수 있다.
  def handle_info({:created_rating, updated_product, product_index}, socket) do
    {:noreply, handle_rating_created(socket, updated_product, product_index)}
  end

  def handle_info({:created_demographic, demographic}, socket) do
    {:noreply, handle_demographic_created(socket, demographic)}
  end

  # product & rating 관련 처리 함수
  def assign_products(%{assigns: %{current_user: current_user}} = socket) do
    assign(socket, :products, list_products(current_user))
  end

  # demographic 관련 처리 함수
  defp list_products(user) do
    Catalog.list_products_with_user_rating(user)
  end

  # ----------- demographic 관련 처리 함수 --------------------
  # To teach the SurveyLive view how to respond to our message
  # handle_info/2는 시스템 또는 백엔드 관련 이벤트를 처리하는 반면,
  # handle_event/3는 프론트엔드 사용자 인터페이스 이벤트를 처리하는 데 사용됨.
  #
  # 해당 project 에서는 handle_event 자체는 자식 component 에서 처리되지만
  # 부모 view 내에서 assgin 정보를 받아서 update 하고, 이에 따라, 등록된 demographic 정보를
  # 보여주는 다른 자식 component 로 전환해 주어야 하므로, 이 작업을 위해 사용됨.

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

  # ----------------- ch09 Distributed Dashboard ---------------
  defp handle_rating_created(
    %{assigns: %{products: products}} = socket,
    updated_product,
    product_index
  ) do
    # 기존 handle_rating_created 함수에 추가
    Endpoint.broadcast(@survey_results_topic, "rating_created", %{}) # dashboard 에서 subscribe 할 broadcast

    socket
    |> put_flash(:info, "Rating submitted successfully")
    |> assign(
      :products,
      List.replace_at(products, product_index, updated_product)
    )

    # Flash Message 는 웹 애플리케이션에서 사용자에게 특정 작업의 결과를 임시적으로 보여주는 짧은 메세지.
    # 예를 들어, 사용자가 양식을 제출하고 성공적으로 처리되었을 때 "저장되었습니다"나 오류가 발생했을 때
    # "오류가 발생했습니다"와 같은 메시지가 플래시 메시지에 해당
   end

end
