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
      offset: type(^page, :integer))
    items = nil #Enum.map(enrollments, &_to_json/1)
    json(conn, %{"page" => page + 1, "items" => items})
  end

end
