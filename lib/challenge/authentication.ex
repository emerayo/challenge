defmodule Challenge.Authentication do
  @moduledoc """
  Responsible for handling API authentication
  """

  import Plug.Conn
  alias Challenge.Account
  alias Challenge.Repo

  def init(opts), do: opts

  def authenticated?(conn) do
    case get_req_header(conn, "authorization") do
      ["Basic " <> attempted_auth] -> verify_account(attempted_auth)
      _                            -> false
    end
  end

  def verify_account(attempted_auth) do
    find_account(attempted_auth) != nil
  end

  def decode_auth(attempted_auth) do
    decoded = Base.decode64!(attempted_auth)
    splitted = String.split(decoded, ":")
    email = Enum.at(splitted, 0)
    password = Enum.at(splitted, 1)

    {email, password}
  end

  def find_account(attempted_auth) do
    {email, password} = decode_auth(attempted_auth)

    Repo.get_by Account, %{email: email, encrypted_password: password}
  end

  def call(conn, _opts) do
    path = conn.request_path
    if authenticated?(conn) || path == "/" || path == "/v1/sign_up" do
      conn
    else
      body = Poison.encode!(%{error: "Unauthorized. Check our API documentation to learn about: https://documenter.getpostman.com/view/7390087/S1LvX9HK"})

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(401, body)
      |> halt
    end
  end
end
