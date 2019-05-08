alias Challenge.Account
alias Challenge.Repo

%Account{email: "admin@bankapi.com", encrypted_password: "1234"} |> Repo.insert!()

%Account{email: "user@users.com", encrypted_password: "4321"} |> Repo.insert!()
