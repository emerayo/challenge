defmodule Challenge.Application do
  use Application
  require Logger

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Plug.Cowboy, scheme: :http, plug: Challenge.HomePlug, options: [port: "PORT" |> System.get_env() |> String.to_integer()]}
    ]
    opts = [strategy: :one_for_one, name: Challenge.Supervisor]

    Logger.info("Starting application...")

    Supervisor.start_link(children, opts)
  end
end
