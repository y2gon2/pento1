defmodule Pento1Web.SurveyLive do
  use Pento1Web, :live_view

  alias Pento1Web.SurveyLive.Component
  alias Pento1.{Survey, Catalog}
  alias Pento1Web.DemographicLive
  alias Pento1Web.RatingLive

  def mount(_params, _session, socket) do
    IO.inspect(socket, label: "socket : ")
    {:ok,
    socket
    |> assign_demographic
    |> assign_products
    }
  end

  # --------- product & rating 관련 처리 함수 ----------------
  def assign_products(%{assigns: %{current_user: current_user}}=socket) do
    assign(socket, :products, list_products(current_user))
  end

  defp list_products(user) do
    Catalog.list_products_with_user_rating(user)
  end

  def handle_info({:created_rating, updated_product, product_index}, socket) do
    {:noreply, handle_rating_created(socket, updated_product, product_index)}
  end

  def handle_rating_created(
    %{assigns: %{products: products}} = socket,
    updated_product,
    product_index
  ) do
    socket
    |> put_flash(:info, "Rating submitted successfully")
    |> assign(
      :products,
      List.replace_at(products, product_index, updated_product)
    )
  end

  # ----------- demographic 관련 처리 함수 --------------------
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