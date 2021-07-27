defmodule BillinhoApi.Bill do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bills" do
    field :amount, :integer
    field :due_date, :date
    field :status, :string, default: "open"

    belongs_to :enrollment, BillinhoApi.Enrollment

    timestamps()
  end

  @doc false
  def changeset(bill, attrs) do
    bill
    |> cast(attrs, [:due_date, :ammount, :status])
    |> validate_required([:due_date, :ammount, :status, :enrollment_id])
    |> validate_inclusion(:status, ["open", "pending", "paid"])
    |> validate_number(:ammount, greater_than: 0)
    |> foreign_key_constraint(:enrollment_id)
  end
end
