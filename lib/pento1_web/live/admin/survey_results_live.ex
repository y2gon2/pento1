defmodule Pento1Web.Admin.SurveyResultsLive do
  use Pento1Web, :live_component
  use Pento1Web, :chart_live

  alias Pento1.Catalog

  def update(assigns, socket) do
    {:ok,
      socket
      |> assign(assigns)
      |> assign_age_group_filter()
      |> assign_products_with_average_ratings()
      |> assign_dataset()
      |> assign_chart()  # ex. column_map: %{category_col: 0, value_cols: [1]}
      |> assign_chart_svg()
    }
  end

  def handle_event(
    "age_group_filter",
    %{"age_group_filter" => age_group_filter},
    socket
  ) do
    {
      :noreply,
      socket
      |> assign_age_group_filter(age_group_filter)
      |> assign_products_with_average_ratings()
      |> assign_dataset()
      |> assign_chart()
      |> assign_chart_svg()
    }
  end

  # ----------------------------------------------------------------------
  # ch09
  # subscribe 를 통해 변경된 상태임을 확인하고 component update 를 진행할 때,
  # 초기 상태 filter 조건인 "all" 로 처리하게 된다. 이는 admin 사용자가 설정한
  # filtering 조건이 매번 자동으로 "all" 로 변경됨을 의미한다.
  # 이를 해결하기 위해 기존 설정값을 그대로 유지하면서 update 를 진행할 수 있도록
  # 이를 재할당해주는 함수를 재 구현 해줌.
  def assign_age_group_filter(
    %{assigns: %{age_group_fliter: age_group_filter} = socket}
   ) do
      assign(socket, :age_group_filter, age_group_filter)
  end

  # ch08 나이 filter assgin 할당 구현
  def assign_age_group_filter(socket) do
    assign(socket, :age_group_filter, "all")
  end

  def assign_age_group_filter(socket, age_group_filter) do
    assign(socket, :age_group_filter, age_group_filter)
  end

  # ----------------------------------------------------------------------
  defp assign_products_with_average_ratings(
    %{assigns: %{age_group_filter: age_group_filter}} = socket
    ) do
      assign(
        socket,
        :products_with_average_ratings,
        get_products_with_average_ratings(%{age_group_filter: age_group_filter})
      )
  end

  defp get_products_with_average_ratings(filter) do
    case Catalog.products_with_average_ratings(filter) do
      [] ->
        Catalog.products_with_zero_ratings()
      products ->
        products
    end
  end

  # ----------------------------------------------------------------------
  # SVG (Scalable Vector Graphics) Chart 생성을 위한 Contex.Dataset 구현
  def assign_dataset(%{
    assigns: %{products_with_average_ratings: products_with_average_ratings}
    } = socket) do
    socket
    |> assign(:dataset, make_bar_chart_dataset(products_with_average_ratings))
  end

  # -> macro 사용으로 bar_chart.ex 내 함수 inject 하는 것으로 변경
  # defp make_bar_chart_dataset(data) do
  #   Contex.Dataset.new(data)
  # end

  # ----------------------------------------------------------------------
  # bar chart 설정값을  socket state 추가 reducer function
  defp assign_chart(%{assigns: %{dataset: dataset}} = socket) do
    assign(socket, :chart, make_bar_chart(dataset))
  end

    # -> macro 사용으로 bar_chart.ex 내 함수 inject 하는 것으로 변경
  # bar chart 설정
  # defp make_bar_chart(dataset) do
  #   Contex.BarChart.new(dataset)
  # end

  # ----------------------------------------------------------------------
  # plot 설정값 assign state 추가
  defp assign_chart_svg(%{assigns: %{chart: chart}} = socket) do
    socket
    # |> assign(:chart_svg, render_bar_chart(chart)) # macro 사용으로 인한 변경
    |> assign(
      :chart_svg,
      render_bar_chart(chart, title(), subtitle(), x_axis(), y_axis())
    )
  end

  # -> macro 사용으로 bar_chart.ex 내 함수 inject 하는 것으로 변경
  # Polt 값 설정
  # defp render_bar_chart(chart) do
  #   Plot.new(500, 400, chart)
  #   |> Plot.titles(title(), subtitle())
  #   |> Plot.axis_labels(x_asis(), y_axis())
  #   |> Plot.to_svg()
  # end

  defp title do
    "Product Ratings"
  end

  defp subtitle do
    "average star ratings per product"
  end

  defp x_axis do
    "products"
  end

  defp y_axis do
    "stars"
  end
end
