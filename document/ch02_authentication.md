## 기본적인 LiveView Authentication 적용

### LiveView 라이브러리가 제공하는 Authentication 을 적용

* Authentication Generator 사용을 위한 phx.gen 추가
```
> mix phx.gen
```
이 중 auth 관련 generator 사용
```
> mix phx.gen.auth Accounts User uers
```
(by ChatGPT)
1. Context ('Accounts'):
Context는 Phoenix에서 도메인 특정 로직을 캡슐화하는 모듈입니다. 이는 데이터베이스와의 상호작용을 관리하고, 애플리케이션의 나머지 부분에 서비스 API를 제공합니다.
"Accounts"는 이 예제에서 생성될 context의 이름입니다. 이 context는 인증과 관련된 모든 함수와 로직을 포함하게 됩니다.

2. Schema ('User'):
Schema는 데이터베이스 테이블의 구조를 설명하는 Elixir 모듈입니다. 이는 테이블의 각 열에 해당하는 필드와 그 타입을 정의합니다.
"User"는 사용자 데이터를 나타내는 schema의 이름입니다. 이 schema는 사용자 데이터를 저장하고 쿼리하는 데 사용됩니다.

3. Plural name of the schema ('users'):
이것은 데이터베이스 내에서 사용될 테이블의 이름입니다. Phoenix는 일반적으로 schema 이름의 복수형을 테이블 이름으로 사용합니다.
"users"는 "User" schema에 대응하는 데이터베이스 테이블의 이름이 됩니다.

```
> mix deps.get
```

* Run Migration
```
> mix ecto.migrate
```
해당 설정 이후 기존 `live "/guess", WrongLive` 를 :require_authenticated_user plug 를 실행하는 scope 로 옮겨서 추가해준다.

따라서 해당 경로 접속은 Authentication 이 필요하며, 해당 인증은 LiveView 에서 재공하는 login / signup page 를 사용하여 회원 등록을 손쉽게 적용할 수 있게 된다.