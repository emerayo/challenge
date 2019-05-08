defmodule Challenge.Repo do
  use Ecto.Repo, otp_app: :challenge

  import Ecto.Changeset
  alias Ecto.Changeset

  def changeset_error_to_string(changeset) do
    Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
