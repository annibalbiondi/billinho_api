defmodule BillinhoApi.Repo.Migrations.CreateBills do
  use Ecto.Migration

  def change do
    create table(:bills) do
      add :due_date, :date, null: false
      add :amount, :integer, null: false
      add :status, :string, null: false, default: "open"
      add :enrollment_id, references(:enrollments, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:bills, [:enrollment_id])
  end
end
