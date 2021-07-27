defmodule BillinhoApi.Repo.Migrations.CreateEnrollments do
  use Ecto.Migration

  def change do
    create table(:enrollments) do
      add :amount, :integer, null: false
      add :installments, :integer, null: false
      add :due_day, :integer, null: false
      add :student_id, references(:students, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:enrollments, [:student_id])
  end
end
