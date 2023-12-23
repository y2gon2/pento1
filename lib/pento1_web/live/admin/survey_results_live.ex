defmodule Pento1Web.Admin.SurveyResultsLive do
  use Pento1Web, :live_component
  alias Pento1.Catalog
  alias Contex.Plot

  def update(assigns, socket) do
    {:ok,
      socket
      |> assign(assigns)
      |> assign_products_with_average_ratings()
      |> assign_dataset()
      |> assign_chart()  # ex. column_map: %{category_col: 0, value_cols: [1]}
      |> assign_chart_svg()
    }
  end

  # ----------------------------------------------------------------------
  def assign_products_with_average_ratings(socket) do
    socket
    |> assign(
      :products_with_average_ratings,
      Catalog.products_with_average_rating()
    )
  end

  # ----------------------------------------------------------------------
  # SVG (Scalable Vector Graphics) Chart 생성을 위한 Contex.Dataset 구현
  def assign_dataset(%{
    assigns: %{products_with_average_ratings: products_with_average_ratings}
    } = socket) do
    socket
    |> assign(:dataset, make_bar_chart_dataset(products_with_average_ratings))
  end

  defp make_bar_chart_dataset(data) do
    Contex.Dataset.new(data)
  end

  # ----------------------------------------------------------------------
  # bar chart 설정값을  socket state 추가 reducer function
  defp assign_chart(%{assigns: %{dataset: dataset}} = socket) do
    socket
    |> assign(:chart, make_bar_chart(dataset))
  end

  # bar chart 설정
  defp make_bar_chart(dataset) do
    Contex.BarChart.new(dataset)
  end

  # ----------------------------------------------------------------------
  # plot 설정값 assign state 추가
  defp assign_chart_svg(%{assigns: %{chart: chart}} = socket) do
    socket
    |> assign(:chart_svg, render_bar_chart(chart))
  end

  # Polt 값 설정
  defp render_bar_chart(chart) do
    Plot.new(500, 400, chart)
    |> Plot.titles(title(), subtitle())
    |> Plot.axis_labels(x_asis(), y_axis())
    |> Plot.to_svg()
  end

  defp title do
    "Product Ratings"
  end

  defp subtitle do
    "average star ratings per product"
  end

  defp x_asis do
    "products"
  end

  defp y_axis do
    "stars"
  end
end
