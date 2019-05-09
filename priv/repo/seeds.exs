alias Challenge.Account
alias Challenge.Repo

email = "admin@bankapi.com"
password = "1234"
result = Repo.get_by Account, %{email: email, encrypted_password: password}

if result == nil do
  %Account{email: email, encrypted_password: password, admin: true} |> Repo.insert!()
end
