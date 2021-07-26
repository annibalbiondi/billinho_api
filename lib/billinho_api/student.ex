defmodule BillinhoApi.Student do
  use Ecto.Schema
  import Ecto.Changeset

  schema "students" do
    field :birthdate, :date
    field :cpf, :string
    field :name, :string
    field :payment_method, :string

    timestamps()
  end

  @doc false
  def changeset(student, attrs) do
    student
    |> cast(attrs, [:name, :cpf, :birthdate, :payment_method])
    |> validate_required([:name, :cpf, :payment_method])
    |> validate_format(:cpf, ~r/^\d{3}\.\d{3}\.\d{3}-\d{2}$/)
    |> validate_inclusion(:payment_method, ["credit_card", "boleto"])
    |> unique_constraint(:cpf)
  end
end
