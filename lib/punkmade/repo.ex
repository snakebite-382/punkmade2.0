defmodule Punkmade.Repo do
  use Ecto.Repo,
    otp_app: :punkmade,
    adapter: Ecto.Adapters.MyXQL
end
