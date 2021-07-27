defmodule BillinhoApi.Repo.Migrations.CreateStudents do
  use Ecto.Migration

  def change do
    create table(:students) do
      add :name, :string, null: false
      add :cpf, :string, null: false
      add :birthdate, :date
      add :payment_method, :string, null: false

      timestamps()
    end

    create unique_index(:students, [:cpf])
  end
end
