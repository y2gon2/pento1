defmodule Pento1.Repo do
  use Ecto.Repo,
    otp_app: :pento1,
    adapter: Ecto.Adapters.Postgres
end
