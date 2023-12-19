defmodule Pento1.Repo.Migrations.AddImageToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :image_upload, :string
    end
  end
end
