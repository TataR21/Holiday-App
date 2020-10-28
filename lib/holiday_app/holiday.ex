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
    |> validate_required([:id_user, :date_start, :date_end, :days, :reason], message: "Pole nie może być puste!")
    |> date_validation(attrs)
  end

  defp date_validation(changeset, attrs) do
    if changeset.valid? == true && changeset.changes != %{} do
      date_start = attrs["date_start"]
      date_end = attrs["date_end"]
      changeset
        |> check_if_day_from_past(date_start)
        |> check_if_end_larger_than_start(date_start,date_end)
    else
      changeset
    end
   end

  defp check_if_day_from_past(changeset, date_start) do
    date = Date.utc_today()
    start_date = Date.from_iso8601!(date_start)
    case Date.compare(date, start_date) do
      :eq -> changeset #poczatek urkopu w dniu dzisiejszym
      :lt -> changeset #ok
      :gt -> Ecto.Changeset.add_error(changeset, :date_start, "Początek urlopu nie może zaczynać się wcześniej niż dzisiaj")
    end
  end

  defp check_if_end_larger_than_start(changeset, date_start, date_end) do
    start_date = Date.from_iso8601!(date_start)
    end_date = Date.from_iso8601!(date_end)

    case Date.compare(start_date, end_date) do
      :eq -> changeset #urlop na jeden dzień
      :lt -> changeset #ok
      :gt -> Ecto.Changeset.add_error(changeset, :date_end, "Koniec urlopu nie może być wcześniej niż początek urlopu!")
    end
  end
end
