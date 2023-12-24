defmodule Pento1.Catalog do
  @moduledoc """
  The Catalog context.
  """

  import Ecto.Query, warn: false
  alias Pento1.Repo

  alias Pento1.Catalog.Product

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products do
    Repo.all(Product)
  end

  @spec list_products_with_user_rating(atom() | %{:id => any(), optional(any()) => any()}) ::
          any()
  def list_products_with_user_rating(user) do
    Product.Query.with_user_ratings(user)
    |> Repo.all()
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  def products_with_average_ratings do
    Product.Query.with_average_ratings()
    |> Repo.all()
  end

  def products_with_average_ratings( %{
    age_group_filter: age_group_filter,
  }) do
    Product.Query.with_average_ratings()
    |> Product.Query.join_users()
    |> Product.Query.join_demographics()
    |> Product.Query.filter_by_age_group(age_group_filter)
    |> Repo.all()
  end
  # 위 pipeline 작업에 대한 처리 과정을 자세하게 서술하면 다음과 같다. (by ChatGPT)

  # 1. Product.Query.with_average_ratings()
  # 이 단계에서는 Product 테이블(p)의 각 레코드에 대해 Rating 테이블(r)을 내부 조인합니다.
  # 조인은 Product의 id와 Rating의 product_id가 일치하는 경우에 수행됩니다.
  # 그런 다음, Product의 id를 기준으로 그룹화하고, 각 제품에 대한 Rating의 평균 점수(stars)를 계산

  # 2. Product.Query.join_users()
  # 이 단계에서는 첫 번째 단계의 결과에 User 테이블(u)을 왼쪽 조인합니다.
  # 조인은 Rating의 user_id와 User의 id가 일치하는 경우에 수행됩니다.
  # :left 조인은 User 정보가 없는 Rating 레코드도 결과에 포함시키며,
  # 이 경우 User 정보는 null로 표시됩니다.

  # 3. Product.Query.join_demographics()
  # 이 단계에서는 두 번째 단계의 결과에 Demographic 테이블(d)을 왼쪽 조인합니다.
  # 조인은 User의 id와 Demographic의 user_id가 일치하는 경우에 수행됩니다.
  # 여기서도 :left 조인이 사용되어 Demographic 정보가 없는 User 레코드는 결과에 포함되지만,
  # 해당 Demographic 정보는 null로 표시됩니다.
  # Product.Query.filter_by_age_group(age_group_filter)
  # 이 단계에서는 age_group_filter 인자에 따라 적절한 연령 그룹 필터를 적용합니다.
  # apply_age_group_filter 함수는 age_group_filter 값에 따라 다양한 조건으로
  # Demographic의 year_of_birth를 필터링합니다.

  # 최종적으로, 이 함수는 평균 평점이 계산된 Product(p)에 대해 해당 평점을 남긴 User(u)와
  # 사용자의 Demographic 정보(d)를 포함하고, 필요한 경우 연령 그룹에 따라 결과를 필터링하는
  # 복합 쿼리를 구성합니다. 결과적으로, 이 쿼리는 제품, 평균 평점, 평점을 남긴 사용자 정보,
  # 사용자의 데모그래픽 정보를 포함한 데이터셋을 반환합니다.


  def products_with_zero_ratings do
    Product.Query.with_zero_ratings()
    |> Repo.all()
  end
end
