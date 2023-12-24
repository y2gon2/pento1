defmodule Pento1.Catalog.Product.Query do
  import Ecto.Query

  alias Pento1.Catalog.Product
  alias Pento1.Survey.{Rating, Demographic}
  alias Pento1.Accounts.User

  # base table (Product) 에 대한 alias 는 자동을 p 로 할당 되는 듯??
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

  # -----------------------------------------------------------------------

  @doc """
  admin - dashboard 에 각 상품의 평균 rating 을 산출하기 위함
  아래 함수를 Ecto Query 문으로 작성하면 다음과 같다.
  ```
  from p in Product,
  join: r in Rating, on: r.product_id == p.id,
  group_by: p.id,
  select: {p.name, fragment("?::float", avg(r.stars))}
  ```
  """
  def with_average_ratings(query \\ base()) do
    query
    |> join_ratings
    |> average_ratings
  end

  defp join_ratings(query) do
    query
    |> join(:inner, [p], r in Rating, on: r.product_id == p.id)
    # :inner - (inner Join) : 양쪽 테이블에서 일치하는 데이터만 선택
    # [p] - Product data 에 대한 별칭 p list. Join 조건을 정의할 때 사용
    # r in Rating - Rating Table 의 별칭 지정, Join 조건의 다른 한쪽을 정의
    # on: r.product_id == p.id - 앞의 세 인자를 통해 접근 table 과
    #                          Join 형태를 결정했으므로, 실제 join 조건을 명시
    #
    # p? r in Rating? => 각각 product 와 Rating 에 대한 alias 임
    # Ecto library 를 사용하여 Query 작업을 할 때, 별칭 (alias) 를 사용함.
    #
    # ex) query = from u in User, where: u.name == "Tom", select: u
    #
    # 위와 같이, 일반적으로 Table(또는 schema module) 로 정의, 생성된 실제 record 를
    # 찾거나, 수정하는 등의 작업을 할 때 alias 를 통해 접근하게 된다.
    # 따라서 u in User 로 별칭을 정의 했을 때,
    # User.name 의 명칭으로 실제 data 를 명시할 수 없다.
    # u.name 을 사용하여야 함
    #
    # 다만 위 code 에서 p 의 경우 alias 정의를 별도로 하지 않았는데 그냥 사용하는게....
    # 그냥 내부적으로 정의되는건지 모르겠음.
  end

  defp average_ratings(query) do
    query
    |> group_by([p], p.id)
    |> select([p, r], {p.name, fragment("?::float", avg(r.stars))})
    # group_by - 앞에서 product_id 가 일치하는 rating 별로 join 처리한 query 를 받아서
    #            다시 product_id 별로 분리한다.(?)
    #
    # select - 반환할 data 에 대한 추가 작업을 정의
    # [p, r] - Product 와 Ratign 의 alias (From p in Product 와 같은 정의는 내부구현인건가?)
    # {p.name, fragment()} - 반환할 결과의 구조(튜플) 정의
    # p.name - 반환하는 data tuple 첫번째 요소는 Product.name 값
    # fragment() - 일반적으로 정형화된 query 가 아닌, 사용자가 직접 database 문법을 사용하여 logic 을 구성할 경우 사용
    # "?::float" - SQL(postgres)에서 타입 캐스팅(type casting). 부동 소수점 type(float) 으로 변환
    # avg(r.stars) - 평점의 평균값을 계산. 그 결과 값은 앞에서 언급한 float type 으로 계산됨.
  end

  def with_zero_ratings(query \\ base()) do
    query
    |> select([p], {p.name, 0})
  end

  # -----------------------------------------------------------------------
  # 아래 함수드릉 admin view 에서 filtering 조건에 따라 가져오는 값을 해당 filter 에 맞게
  # 정리하여 받기 위한 함수들

  def join_users(query \\ base()) do
    query
    |> join(:left, [p, r], u in User, on: r.user_id == u.id)
    # 왼쪽 table (p Product) 의 모든 record 에 조건이 만족되는 오른쪽 table record (u User) 를 join
    # 만약 해당하는 오른쪽 table record 가 없으면 null 로 처리
    # ?? 왼쪽 table 은 p? r?
    # -> 여기에서 두번째 [p, r] 은 이미 이전 단계의 query 문 언급한 alias 를 모두 그대로 가져온다.
    #    즉 r record 에 일치하는 user_id 를 가진 u record 를 이전 작업된 결과 query 문 (p base) 에 join 하는 것
  end

  def join_demographics(query \\ base()) do
    query
    |> join(:left, [p, r, u, d], d in Demographic, on: d.user_id == u.id)
    # 위와 마찬가지로 `[p, r, u, d]` 에서 p, r 은 이전 query 작업 내용을 담고(?) 있으며
    # 여기서는 d(demographic record) 의 user_id 가 일치하는 u record 를 이전 query 결과 (p base)에 join 한다.
  end

  def filter_by_age_group(query \\ base(), filter) do
    query
    |> apply_age_group_filter(filter)
  end

  defp apply_age_group_filter(query, "18 and under") do
    birth_year = DateTime.utc_now().year - 18

    query
    |> where([p, r, u, d], d.year_of_birth >= ^birth_year)
  end

  defp apply_age_group_filter(query, "18 to 25") do
    birth_year_max = DateTime.utc_now().year - 18
    birth_year_min = DateTime.utc_now().year - 25

    query
    |> where(
      [p, r, u, d],
      d.year_of_birth >= ^birth_year_min and d.year_of_birth <= ^birth_year_max
    )
  end

  defp apply_age_group_filter(query, "25 to 35") do
    birth_year_max = DateTime.utc_now().year - 25
    birth_year_min = DateTime.utc_now().year - 35

    query
    |> where(
      [p, r, u, d],
      d.year_of_birth >= ^birth_year_min and d.year_of_birth <= ^birth_year_max
    )
  end

  defp apply_age_group_filter(query, "35 and up") do
    birth_year = DateTime.utc_now().year - 35

    query
    |> where(
      [p, r, u, d],
      d.year_of_birth <= ^birth_year
    )
  end

  defp apply_age_group_filter(query, _filter) do
    query
  end
end
