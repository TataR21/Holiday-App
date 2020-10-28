defmodule HolidayAppWeb.Holiday do
  use Ecto.Schema
  import Ecto.Changeset

  schema "holiday" do

    field :id_user, :integer
    field :date_start, :string
    field :date_end, :string
    field :days, {:array, :string}
    field :reason, :string

    timestamps()
  end

  @doc false
  def changeset(holiday, attrs \\ %{}) do
    holiday
    |> cast(attrs, [:id_user, :date_start, :date_end, :days, :reason])
    |> validate_required([:id_user, :date_start, :date_end, :days, :reason])
  end
end
