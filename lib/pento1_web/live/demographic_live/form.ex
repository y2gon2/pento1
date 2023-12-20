defmodule Pento1Web.DemographicLive.Form do
  use Pento1Web, :live_component
  alias Pento1.Survey
  alias Pento1.Survey.Demographic

  def update(assigns, socket) do
    IO.inspect(assigns, label: "assigns")
    IO.inspect(socket, label: "socket")
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_demographic()
      |> clear_form()
    }
  end

  # survey_live mount/1 와 마찬가지로 upate 할 때도 socket assign :demographic 에 user_id 값을 할당한다.
  defp assign_demographic(%{assigns: %{current_user: current_user}} = socket) do
    assign(socket, :demographic, %Demographic{user_id: current_user.id})
  end

  # 유효성 검사한 form data 를 :form assign 에 넣는다
  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  # changeest 유효성 검사를 진행 후 `assign_form/2` 실행
  defp clear_form(%{assigns: %{demographic: demographic}} = socket) do
    assign_form(socket, Survey.change_demographic(demographic))
  end

  def handle_event("save", %{"demographic" => demographic_params}, socket) do
    IO.puts("Handling `save` event and saving dempgraphic record...")
    IO.inspect(demographic_params, label: "demographic_params ")

    params = params_with_user_id(demographic_params, socket)
    {:noreply, save_demographic(socket, params)}
  end


  # def handle_event("validate", %{"demographic" => demographic_params}, socket) do
  #   params = params_with_user_id(demographic_params, socket)
  #   {:noreply, validate_demographic(socket, params)}
  # end

  defp save_demographic(socket, demographic_params) do
    case Survey.create_demographic(demographic_params) do
      {:ok, demographic} ->
        send(self(), {:created_demographic, demographic})
        socket

      {:error, %Ecto.Changeset{} = changeset} ->
        assign_form(socket, changeset)
    end
  end

  def params_with_user_id(params, %{assigns: %{current_user: current_user}}) do
    params
    |> Map.put("user_id", current_user.id)
  end
end
