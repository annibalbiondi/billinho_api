defmodule BillinhoApi.Utils do

  def params_to_integer(params) do
    params_int = Enum.into(
      Enum.map(params, fn {k, v} ->
        integer_value = Integer.parse(v, 10)
        case integer_value do
          {int, decimal} when decimal == "" -> {k, int}
          _ -> {k, :error}
        end
      end),
      %{})
    errors = Enum.into(Enum.reduce(
          params_int,
          %{},
          fn x, acc ->
            {name, value} = x
            if value == :error do
              Map.put_new(acc, name, ["must be an integer"])
            else
              acc
            end
          end), %{})
    if map_size(errors) > 0 do
      {:error, errors}
    else
      {:ok, params_int}
    end
  end

end
