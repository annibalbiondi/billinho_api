defmodule BillinhoApiWeb.EnrollmentController do
  use BillinhoApiWeb, :controller

  alias BillinhoApi.{Enrollment, Bill, Repo}
  alias BillinhoApiWeb.ErrorHelpers
  import Ecto.Query
  
  def index(conn, %{"page" => page_param,
		    "count" => count_param} = _params) do
    # TODO: Definir valores padrão para os parâmetros?
    page = String.to_integer(page_param) - 1
    count = String.to_integer(count_param)
    
    enrollments =  Repo.all(from s in Enrollment,
                            limit: type(^count, :integer),
                            offset: type(^page, :integer),
                            preload: [:bills])
    json(conn,
      %{"page" => page + 1,
	"items" => Enum.map(enrollments, &_enrollment_to_json/1)})
  end

  def create(conn, params) do
    {result, values} = _params_to_integer(params)
    if result == :error do
      conn
      |> send_resp(
        400,
      Jason.encode!(values))
    else
      params_int = values
      IO.puts Jason.encode!(params_int)
      enrollment = Enrollment.changeset(%Enrollment{}, params_int)
      if not enrollment.valid? do
        conn
        |> send_resp(
          400,
        Jason.encode!(Ecto.Changeset.traverse_errors(
              enrollment, &ErrorHelpers.translate_error/1)))
      else
        due_day = params_int["due_day"]
        {{year, month, day}, _} = :calendar.local_time()
        {:ok, possible_due_date} = Date.new(
	  year,
	  month,
	  Enum.min([
	    due_day,
	    :calendar.last_day_of_the_month(year, month)
	  ]))
        bills = _build_bills(Map.put_new(params_int, "due_date",
	    (if (possible_due_date.day > day),
	    do: possible_due_date,
	        else: _next_due_date(possible_due_date, due_day))))
        enrollment_with_bills = Ecto.Changeset.put_assoc(enrollment, :bills, bills)
        {result, value} = Repo.insert(enrollment_with_bills)
        if result == :ok do
          json(conn, _enrollment_to_json(value))
        else
          conn
          |> send_resp(
            400,
          Jason.encode!(Ecto.Changeset.traverse_errors(
                value, &ErrorHelpers.translate_error/1)))
        end
      end
    end
  end
  

  def _params_to_integer(params) do
    params_int = Enum.into(
      Enum.map(params, fn {k, v} ->
        integer_value = Integer.parse(v, 10)
        case integer_value do
          {int, decimal} when decimal == "" -> {k, int}
          _ -> {k, :error}
        end
      end),
      %{})
    IO.puts Jason.encode!(params_int)
    errors = Enum.into(Enum.reduce(
          params_int,
          %{},
          fn x, acc ->
            {name, value} = x
            if value == :error do
              Map.put_new(acc, name, ["must be an integer"])
            else
              acc
            end
          end), %{})
    if map_size(errors) > 0 do
      {:error, errors}
    else
      {:ok, params_int}
    end
  end

  def _build_bills(%{"amount" => amount,
		     "installments" => installments,
		     "due_day" => due_day,
		     "due_date" => due_date
		    } = _params) do
    if (installments == 0) do
      []
    else
      bill_amount = div(amount, installments)
      [Ecto.Changeset.change(%Bill{}, due_date: due_date,
	  amount: bill_amount)
       | _build_bills(
	 %{
	   "amount" => amount - bill_amount,
	   "installments" => installments - 1,
	   "due_day" => due_day,
	   "due_date" => _next_due_date(due_date, due_day)
	 })]
    end
  end

  def _next_due_date(due_date, due_day) do
    month = Enum.max([rem(due_date.month + 1, 13), 1])
    year = if month > due_date.month, do: due_date.year, else: due_date.year + 1
    day = Enum.min([due_day, :calendar.last_day_of_the_month(year, month)])
    {:ok, next_due_date} = Date.new(year, month, day)
    next_due_date
  end

  def _enrollment_to_json(enrollment) do
    %{
      id: enrollment.id,
      student_id: enrollment.student_id,
      amount: enrollment.amount,
      installments: enrollment.installments,
      due_day: enrollment.due_day,
      bills: Enum.map(enrollment.bills, &_bill_to_json/1)
    }
  end

  def _bill_to_json(bill) do
    due_date = bill.due_date
    dd = due_date.day |> Integer.to_string |> String.pad_leading(2, "0")
    mm = due_date.month |> Integer.to_string |> String.pad_leading(2, "0")
    yyyy = due_date.year |> Integer.to_string
    %{
      id: bill.id,
      due_date: "#{dd}/#{mm}/#{yyyy}",
      status: bill.status,
      amount: bill.amount
    }
  end

end
