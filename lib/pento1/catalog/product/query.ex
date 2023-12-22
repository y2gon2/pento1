defmodule Pento1.Catalog.Product.Query do
  import Ecto.Query

  alias Pento1.Catalog.Product
  alias Pento1.Survey.{Rating, Demographic}
  alias Pento1.Accounts.User

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
end
