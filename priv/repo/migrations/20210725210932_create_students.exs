defmodule BillinhoApi.Repo.Migrations.CreateStudents do
  use Ecto.Migration

  def change do
    create table(:students) do
      add :name, :string
      add :cpf, :string
      add :birthdate, :date
      add :payment_method, :string

      timestamps()
    end

    create unique_index(:students, [:cpf])
  end
end
