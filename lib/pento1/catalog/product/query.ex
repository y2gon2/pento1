defmodule Pento1.Catalog.Product.Query do
  import Ecto.Query

  alias Pento1.Catalog.Product
  alias Pento1.Survey.Rating

  def base, do: Product

  @doc """
  제품 정보를 load 할 때, 해당 제품에 대한 평가 정보도 함께 load 하기 위해서
  해당 제품을 평가한 user_id 를 가지고 rating 정보를 찾아서 이를 preload 해준다.
  """
  def with_user_ratings(user) do
    base()
    |> preload_user_ratings(user)
  end

  def preload_user_ratings(query, user) do
    ratings_query = Rating.Query.preload_user(user)

    query
    |> preload(ratings:  ^ratings_query)
  end
end
