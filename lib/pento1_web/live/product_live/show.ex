defmodule Pento1Web.ProductLive.Show do
  use Pento1Web, :live_view

  alias Pento1.Catalog
  alias Pento1Web.Presence

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    product = Catalog.get_product!(id)
    maybe_track_user(product, socket)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:product, product)}
  end

  def maybe_track_user(
    product,
    %{assigns: %{live_action: :show, current_user: current_user}} = socket
  ) do
    IO.inspect(self(), label: "self()111")
    if connected?(socket) do
      Presence.track_user(self(), product, current_user.email)
    end
  end
  def maybe_track_user(_product, _socket), do: nil

  defp page_title(:show), do: "Show Product"
  # defp page_title(:edit), do: "Edit Product"
end
