defmodule BillinhoApi.Repo do
  use Ecto.Repo,
    otp_app: :billinho_api,
    adapter: Ecto.Adapters.Postgres
end
