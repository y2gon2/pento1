## LiveView @uploads assignment 에 대해서 알려줘 (to ChatGPT)

Phoenix LiveView의 @uploads는 파일 업로드를 처리하기 위한 특별한 어사인먼트(assignment)입니다. 이 기능은 사용자가 파일을 업로드할 때 실시간으로 이를 처리하고, 파일의 상태를 추적할 수 있게 해줍니다. 이를 통해 복잡한 파일 업로드 로직을 간단하고 효율적으로 구현할 수 있습니다.

@uploads의 주요 특징과 사용 방법은 다음과 같습니다:

파일 업로드 구성

@uploads는 Phoenix.LiveView.UploadConfig를 사용하여 설정됩니다. 이를 통해 업로드에 대한 다양한 옵션을 지정할 수 있습니다. 예를 들어, 허용되는 파일 타입, 파일 크기 제한, 저장 위치 등을 설정할 수 있습니다.
실시간 프로세싱

사용자가 파일을 업로드하면, LiveView는 해당 파일을 실시간으로 처리합니다. 이는 사용자 인터페이스에 즉시 반영되어, 업로드 진행 상태나 성공/실패 여부를 바로 보여줄 수 있습니다.
폼과의 통합

@uploads는 폼과 통합되어 사용됩니다. HTML 폼에 phx-change 이벤트를 사용하여 파일이 선택되었을 때 LiveView 서버에 알릴 수 있습니다.
에러 핸들링

업로드 중 발생하는 오류는 자동으로 처리되며, 이를 사용자에게 피드백할 수 있는 방법을 제공합니다.
업로드 진행 상태 추적

파일 업로드의 진행 상태는 @uploads 어사인먼트를 통해 실시간으로 추적됩니다. 이를 활용해 사용자에게 진행률 바나 업로드 상태 메시지를 보여줄 수 있습니다.
사용 예시: 
(현재 구현하고 있는 code 와 event 처리 부분이 다름. 아마도 구현 예제에서는 drag&drop 기능을 포함하고 있으므로 단순 클릭에 의한 event 처리와는 다르기 때문에 구현에서는 `update/2` 함수에 upload 상태를 추가하는것으로 구현됨. )

```elixir
defmodule MyAppWeb.PhotoLive do
  use Phoenix.LiveView
  alias Phoenix.LiveView.UploadConfig

  def render(assigns) do
    ~L"""
    <%= f = form_for @changeset, "#", phx_change: :validate, phx_submit: :save %>
      <%= file_input f, :photo, phx_hook: "PhoenixLiveView.Upload" %>
      <%= live_file_input @uploads.photo %>
      <%= submit "Save" %>
    </form>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, uploads: %{})}
  end

  def handle_event("validate", %{"photo" => photo}, socket) do
    upload_config = UploadConfig.new(:photo, accept: ~w(.jpg .jpeg .png), max_entries: 2)
    {:noreply, socket |> put_upload(:photo, upload_config)}
  end
end
```

이 예시에서는 사용자가 사진을 업로드할 수 있는 폼을 만들고, @uploads를 사용하여 업로드를 관리합니다.