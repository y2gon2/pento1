defmodule Pento1Web.PromoLive do
  use Pento1Web, :live_view
  alias Pento1.Promo
  alias Pento1.Promo.Recipient

  def mount(_params, _session, socket) do
    sock = socket
      |> assign_recipient()
      |> clear_form()

    # IO.inspect(sock, label: "Socket data")
    {:ok, sock}
  end

  def handle_event(
    "validate",
    %{"recipient" => recipient_params},
    %{assigns: %{recipient: recipient}} = socket
    ) do

    changeset =
      recipient
      |> Promo.change_recipient(recipient_params)
      |> Map.put(:action, :validate) # 버튼을 누르지 않은 상태 (이벤트 발생 X ) 에서도 :action 속성이 :validate 로 error 를 발생하지 않도록

      # IO.inspect(socket, label: "Socket data")
      # IO.inspect(changeset, label: "event data")

      # assign_form/2 reducer 를 사용하여 (change_set/3 을 통과한) form data 를 socket 에 추가
      {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"recipient" => recipient_params}, socket) do
    case Promo.send_promo(socket.assigns.recipient, recipient_params) do
      {:ok, _recipient} ->
        {:noreply,
          socket
          |> put_flash(:info, "Sent promo!")
          |> clear_form()}
      {:error, %Ecto.Changeset{} = changeset} ->
        {
          :noreply,
          socket
          |> put_flash(:error, "Failed to send promo")
          |> assign_form(changeset)}
    end
  end

  def assign_recipient(socket) do
    socket
    |> assign(:recipient, %Recipient{}) # socket 내 assign map 에 key-vlaue 추가
  end

  def clear_form(socket) do
    form =
      socket.assigns.recipient
      |> Promo.change_recipient() # Recipient 구조체 정보 -> changeset 을 적용
      |> to_form()    # Phoenix.HTML.Form 로 변환

    assign(socket, :form, form)
  end

  def assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
