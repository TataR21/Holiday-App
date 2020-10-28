defmodule HolidayApp.Repo.Migrations.Holiday do
  use Ecto.Migration

  def change do
    create table(:holiday) do
      add :id_user, :integer
      add :date_start, :string
      add :date_end, :string
      add :days, {:array, :string}
      add :reason, :string

      timestamps()
    end
  end
end
