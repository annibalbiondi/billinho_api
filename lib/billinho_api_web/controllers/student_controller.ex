defmodule BillinhoApiWeb.StudentController do
  use BillinhoApiWeb, :controller

  def index(conn, %{"page" => page, "count" => count} = params) do
    # TODO: Valores padrão para os parâmetros?
    json(conn, %{"page" => page, "count" => count})
  end

  def create(conn, %{"name" => name, "cpf" => cpf, "birthdate" => birthdate, "payment_method" => payment_method} = params) do
    # TODO: Mensagem de erro amigável para a ausência de um dos parâmetros
    json(conn, %{"name" => name, "cpf" => cpf, "birthdate" => birthdate, "payment_method" => payment_method})
  end
end
