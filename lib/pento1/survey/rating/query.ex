defmodule Pento1.Survey.Rating.Query do
  import Ecto.Query

  alias Pento1.Survey.Rating

  def base, do: Rating

  def preload_user(user) do
    base()
    |> for_user(user)
  end

  defp for_user(query, user) do
    query
    |> where([r], r.user_id == ^user.id)
  end
end
