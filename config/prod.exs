use Mix.Config

port =
  case System.get_env("PORT") do
    port when is_binary(port) -> String.to_integer(port)
    nil -> 80 # default port
  end

config :challenge, port: port
