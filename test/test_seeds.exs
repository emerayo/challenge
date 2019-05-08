alias Challenge.Account
alias Challenge.Repo

%Account{email: "admin@bankapi.com", encrypted_password: "1234"} |> Repo.insert!()
