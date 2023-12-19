defmodule Pento1.Survey.Demographic.Query do
  @moduledoc """
  Construct Demographic.Query and safely interpolates variables into this Ecto queries with user_id
  """
  import Ecto.Query
  alias Pento1.Survey.Demographic

  def base do
    Demographic
  end

  def for_user(query \\ base(), user) do
    query
    |> where([d], d.user_id == ^user.id)
  end
end
