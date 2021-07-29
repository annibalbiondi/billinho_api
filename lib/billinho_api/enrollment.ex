defmodule BillinhoApi.Enrollment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "enrollments" do
    field :amount, :integer
    field :due_day, :integer
    field :installments, :integer
    field :student_id, :id
    
    has_many :bills, BillinhoApi.Bill

    timestamps()
  end

  @doc false
  def changeset(enrollment, attrs) do
    enrollment
    |> cast(attrs, [:amount, :installments, :due_day, :student_id])
    |> validate_required([:amount, :installments, :due_day, :student_id])
    |> validate_number(:amount, greater_than: 0)
    |> validate_number(:installments, greater_than: 1)
    |> validate_inclusion(:due_day, 1..31)
    |> foreign_key_constraint(:student_id)
  end
end
