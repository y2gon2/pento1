defmodule Pento1Web.RatingLive.Form do
  use Pento1Web, :live_component
  alias Pento1.Survey
  alias Pento1.Survey.Rating

  def update(assigns, socket) do
    {:ok,
    socket
    |> assign(assigns)
    |> assign_rating()
    |> clear_form()
    }
  end

  def handle_event("save", %{"rating" => rating_params}, socket) do
    {:noreply, save_rating(socket, rating_params)}
  end

  defp save_rating(
    %{assigns: %{product_index: product_index, product: product}} = socket,
    rating_params
  ) do
    case Survey.create_rating(rating_params) do
      {:ok, rating} ->
        product = %{product | rating: [rating]}
        send(self(), {:created_rating, product, product_index})
        socket

      {:error, %Ecto.Changeset{} = changeset} ->
        assign_form(socket, changeset)
      # 평가 데이터 저장 시 오류가 발생했을 때 (예: 유효하지 않은 입력 값),
      # 해당 오류 정보를 담고 있는 changeset을 사용하여 오류정보 제공
    end
  end

  def assign_rating(%{assigns: %{current_user: user, product: product}} = socket) do
    assign(socket, :rating, %Rating{user_id: user.id, product_id: product.id})
  end

  def clear_form(%{assigns: %{rating: rating}} = socket) do
    assign_form(socket, Survey.change_rating(rating))
  end

  def assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
