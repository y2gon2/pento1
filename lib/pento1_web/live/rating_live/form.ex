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
