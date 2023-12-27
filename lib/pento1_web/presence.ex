defmodule Pento1Web.Presence do
  use Phoenix.Presence,    # Presen behaviour code 주입
  otp_app: :pento1,
  pubsub_server: Pento1.PubSub
  # otp_app: :pento를 명시하는 이유는 Phoenix.Presence 모듈이 특정 애플리케이션의
  # 구성 설정을 참조할 수 있도록 하기 위함입니다. 이 구성은 Phoenix.Presence 모듈이
  # 사용할 구체적인 설정을 제공합니다. 이 설정은 Phoenix 애플리케이션의 일부이지만,
  # Phoenix.Presence가 사용하는 특정 설정은 :pento 애플리케이션에 정의되어 있을 수 있습니다.
  #
  # Phoenix.Presence 모듈이 실행하는 프로세스는 Phoenix 애플리케이션의 일부입니다.
  # 이 프로세스는 독립적인 애플리케이션으로 실행되지 않습니다. 대신, 그것은 전체 Phoenix
  # 애플리케이션의 컨텍스트 내에서 작동합니다. 그러나, Phoenix.Presence는 애플리케이션의
  # 특정 부분(여기서는 :pento)의 설정을 사용하여 해당 모듈의 행동을 구성합니다.
  #
  # otp_app: :pento를 명시하는 것은 다음과 같은 목적을 가집니다:
  #
  # 1. 구성 설정의 접근:
  # Phoenix.Presence 모듈이 :pento 애플리케이션의 구성 설정에 접근할 수 있도록 합니다.
  # 이 설정은 Phoenix.Presence의 동작을 구성하는 데 필요한 정보(예: 데이터베이스 연결 정보,
  # 환경별 설정 등)를 포함할 수 있습니다.
  #
  # 2. 모듈화 및 분리:
  # 애플리케이션의 각 부분이 자체 구성을 가질 수 있게 함으로써, 코드의 모듈화와 분리를
  # 촉진합니다. 이는 유지 관리와 확장성을 향상시키는 데 도움이 됩니다.
  #
  # 결론적으로, otp_app: :pento 설정은 Phoenix.Presence 모듈이 특정 Phoenix 애플리케이션의
  # 설정을 사용하여 구성되도록 하는 메커니즘입니다. 이는 Phoenix 애플리케이션 내에서
  # 모듈의 유연성과 구성 가능성을 증가시킵니다.

  alias Pento1Web.Presence

  @user_activity_topic "user_activity"

  def track_user(pid, product, user_email) do
    # 필요한 정보를 다른 사용자가 추적할 수 있도록 PubSub 에 해당 정보를 전송
    # 해당 함수가 call 될 때마다 자동으로 전송됨.
    Presence.track(
      pid,
      @user_activity_topic,
      product.name,
      %{users: [%{email: user_email}]}
    )
  end
end
