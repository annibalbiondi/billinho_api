defmodule BillinhoApiWeb.StudentController do
  use BillinhoApiWeb, :controller

  alias BillinhoApi.{Student, Repo}
  import Ecto.Query
  
  def index(conn, %{"page" => page_param, "count" => count_param} = _params) do
    # TODO: Definir valores padrão para os parâmetros?
    page = String.to_integer(page_param) - 1
    count = String.to_integer(count_param)
    
    students =  Repo.all(from s in Student,
      limit: type(^count, :integer),
      offset: type(^page, :integer))
    items = Enum.map(students, &_to_json/1)
    json(conn, %{"page" => page + 1, "items" => items})
  end

  def create(conn,
    %{
      "name" => name,
      "cpf" => cpf,
      "payment_method" => payment_method
    } = params) do
    student = _from_json(params)
    if student.valid? do
      {result, inserted} = Repo.insert(student)
      if result == :ok do
	json(conn, %{"id" => inserted.id})
      else
	conn
	|> send_resp(400, "")
      end
    else
      conn
      |> send_resp(400, "")
    end
  end
  
  def _to_json(student) do
    birthdate = student.birthdate
    if is_nil(birthdate) do
      %{
	id: student.id,
	name: student.name,
	cpf: student.cpf,
	payment_method: student.payment_method
      }
    else
      dd = birthdate.day |> Integer.to_string |> String.pad_leading(2, "0")
      mm = birthdate.month |> Integer.to_string |> String.pad_leading(2, "0")
      yyyy = birthdate.year |> Integer.to_string
      %{
	id: student.id,
	name: student.name,
	cpf: student.cpf,
	birthdate: "#{dd}/#{mm}/#{yyyy}",
	payment_method: student.payment_method
      }
    end
  end

  def _from_json(student) do
    birthdate = Map.get(student, "birthdate")
    if not is_nil(birthdate) do
      [dd, mm, yyyy] = String.split(student.birthdate, "/")
      {:ok, birthdate} = Date.from_iso8601("#{yyyy}-#{mm}-#{dd}")
    end
    Student.changeset(%Student{},
      %{
	name: student["name"],
	cpf: student["cpf"],
	birthdate: birthdate,
	payment_method: student["payment_method"]
      })
  end
    
end
