defmodule Pento1Web.ProductLive.Index do
  use Pento1Web, :live_view

  alias Pento1.Catalog
  alias Pento1.Catalog.Product

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :products, Catalog.list_products())}
  end
  # stream/3
  # stream(socket, :products, Catalog.list_products())를 호출할 때, :streams라는 키가 소켓 할당에 추가되며,
  # 이는 템플릿에서 @streams로 사용할 수 있습니다.
  # :streams 키 아래에서, :products라는 키를 가진 맵을 찾을 수 있으며, 이는 모든 product record 를 의미한다.
  # 이 데이터는 템플릿에서 다음과 같이 접근가능
  # 1. @streams.products. 템플릿이 렌더링될 때, @streams에 할당된 데이터는 소켓에서 분리되어 클라이언트 (DOM 자체)에 저장
  # 2. 나중에, LiveView 스트림 API를 사용하여 @streams.products에 저장된 데이터를 업데이트하거나 삭제할 때,
  #    LiveView는 클라이언트 측에 저장된 데이터에 그 변경사항을 적용함.
  #
  # 이는 LiveView를 빠르고 효율적으로 이용하게 하며, 서버에 큰 데이터셋을 저장할 필요가 없으며,
  # 그 데이터셋을 유지하기 위해 매번 client-server 사이에 큰 페이로드를 보낼 필요가 없어짐.

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, Catalog.get_product!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, %Product{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Products")
    |> assign(:product, nil)
  end

  @impl true
  def handle_info({Pento1Web.ProductLive.FormComponent, {:saved, product}}, socket) do
    {:noreply, stream_insert(socket, :products, product)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Catalog.get_product!(id)
    {:ok, _} = Catalog.delete_product(product)

    {:noreply, stream_delete(socket, :products, product)}
  end
end
