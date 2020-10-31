defmodule HolidayApp.HolidayModuleTest do
  use HolidayApp.DataCase
  alias HolidayAppWeb.Holiday
  import HolidayApp.HolidayModule

  describe "holiday_module" do
    @attrs1 %{"id_user" => 1, "date_start" => "2020-11-02", "date_end" => "2020-11-05", "reason" => "Urlopik", "days" => ["2020-11-02", "2020-11-03", "2020-11-04", "2020-11-05"]}
    @list_day1 ["2020-11-06", "2020-11-07"]
    @list_day2 ["2020-11-02", "2020-11-03", "2020-11-04", "2020-11-05", "2020-11-06"]
    @list_day3 ["2020-11-02", "2020-11-03", "2020-11-04", "2020-11-05"]
    @date_start "2020-11-01"
    @date_end "2020-11-30"


    test "check_days_overlap error" do
      changeset = Holiday.changeset(%Holiday{}, @attrs1)
      changeset = check_days_overlap(@list_day1, @list_day2, changeset)
      assert %{date_start: ["Przedziały nie mogą się nakładać!"]} = errors_on(changeset)
    end

    test "check_days_overlap valid" do
      changeset = Holiday.changeset(%Holiday{}, @attrs1)
      changeset = check_days_overlap(@list_day1, @list_day3, changeset)
      assert %{} = errors_on(changeset)
    end

    test "check_if_the_days_are_used error" do
      changeset = Holiday.changeset(%Holiday{}, @attrs1)
      list_days = list_of_days(@date_start, @date_end)
      changeset = check_if_the_days_are_used(@list_day1, list_days, changeset)
      assert %{date_start: ["Liczba dni urlopowych została wykorzystana.
      Można wykorzystać maksymalnie 20 dni. Wybierz krótszy przedział"]} = errors_on(changeset)
    end

    test "check_if_the_days_are_used valid" do
      changeset = Holiday.changeset(%Holiday{}, @attrs1)
      changeset = check_if_the_days_are_used(@list_day1, @list_day2, changeset)
      assert %{} = errors_on(changeset)
    end
  end
end
