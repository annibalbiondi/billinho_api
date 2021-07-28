defmodule BillinhoApiWeb.EnrollmentController do
  use BillinhoApiWeb, :controller

  alias BillinhoApi.{Enrollment, Bill, Repo}
  import Ecto.Query
  
  def index(conn, %{"page" => page_param, "count" => count_param} = _params) do
    # TODO: Definir valores padrão para os parâmetros?
    page = String.to_integer(page_param) - 1
    count = String.to_integer(count_param)
    
    enrollments =  Repo.all(from s in Enrollment,
      limit: type(^count, :integer),
      offset: type(^page, :integer),
      preload: [:bills])
    items = Enum.map(enrollments, &_enrollment_to_json/1)
    json(conn, %{"page" => page + 1, "items" => items})
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
