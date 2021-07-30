defmodule BillinhoApiWeb.StudentController do
  use BillinhoApiWeb, :controller

  alias BillinhoApi.{Student, Repo, Utils}
  alias BillinhoApiWeb.ErrorHelpers
  import Ecto.Query
  
  def index(conn, %{"page" => _, "count" => _} = params) do
    {result, values} = Utils.params_to_integer(params)

    if result == :error do
      conn
      |> send_resp(400, Jason.encode!(values))
    else
      errors = Enum.reduce(values, %{}, fn param, acc ->
        case param do
          {name, value} when value <= 0 ->
            Map.put_new(acc, name, ["must be positive"])
          _ ->
            acc
        end
      end)
      if map_size(errors) > 0 do
        conn
        |> send_resp(400, Jason.encode!(errors))
      else
        %{"page" => page, "count" => count} = values
        students =  Repo.all(from s in Student,
          limit: type(^count, :integer),
          offset: type(^page - 1, :integer))
        json(conn, %{"page" => page ,
                     "items" => Enum.map(students, &_to_json/1)})
      end
    end
  end

  def create(conn, params) do
    student = _from_json(params)
    unless is_nil(Map.get(student, :error)) do
      conn
        |> send_resp(400, Jason.encode!(student.error))
    else
      if student.valid? do
        {result, inserted} = Repo.insert(student)
        if result == :ok do
          json(conn, %{"id" => inserted.id})
        else
          conn
            |> send_resp(
                400,
                Jason.encode!(Ecto.Changeset.traverse_errors(
                    inserted, &ErrorHelpers.translate_error/1)))
        end
      else
        conn
          |> send_resp(
              400,
              Jason.encode!(Ecto.Changeset.traverse_errors(
                  student, &ErrorHelpers.translate_error/1)))
      end
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
    {result, birthdate} = unless is_nil(student["birthdate"]) do
      [dd, mm, yyyy] = String.split(student["birthdate"], "/")
      Date.from_iso8601("#{yyyy}-#{mm}-#{dd}")
    else
      {:ok, nil}
    end
    if result == :ok do
      Student.changeset(%Student{},
        %{
          name: student["name"],
          cpf: student["cpf"],
          birthdate: birthdate,
          payment_method: student["payment_method"]
        })
    else
      %{error: %{"birthdate" => ["is unparseable"]}}
    end
  end

end
