alias Challenge.Account
alias Challenge.Repo

%Account{email: "admin@bankapi.com", encrypted_password: "1234", admin: true} |> Repo.insert!()
# AUTH = Basic YWRtaW5AYmFua2FwaS5jb206MTIzNA==

%Account{email: "user@users.com", encrypted_password: "4321"} |> Repo.insert!()
# AUTH = Basic dXNlckB1c2Vycy5jb206NDMyMQ==
