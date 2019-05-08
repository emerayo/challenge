# Challenge

A small bank API system made for a challenge

### About

This project was written in Elixir and using Cowboy for handling the HTTP requests and Ecto for managing the database.

The features are: sign_up, withdrawal, transfer money and see all transactions.

### Dependencies

* [Elixir](https://elixir-lang.org/install.html) - 1.8.1

* [Postgres](https://www.postgresql.org/docs/10/tutorial-install.html) - 10

### Setup for development

First of all, need to export  your environment variables accordingly to your system setup.

```

$ export DATABASE_URL='ecto://postgres:postgres@localhost/challenge_repo'
$ export PORT='8080'

```

Install all code dependencies:

```

$ mix deps.get

```

Create the database and run all migrations:

```

$ mix ecto:setup

```

### Running the application

Simply run the command below:

```

$ mix run --no-halt

```

To stop it, press twice `Ctrl + C`.

You can now send your requests to [http://localhost:8080](http://localhost:8080) or use the port configured in your environment variables.

### Running tests

To run the tests suite, pass your environment variables and run this command:

Make sure to add `_test` to your database name so it will not affect your development database.

```

$ MIX_ENV=test PORT=8080 DATABASE_URL='ecto://postgres:postgres@localhost/challenge_repo_test' mix tests

```

### Ensuring code consistency

To run [Credo](https://github.com/rrrene/credo) and make sure the code is consistent, run this command:

```

$ mix credo --strict

```

## Deploying to Heroku

First, make sure you have Heroku properly configured in your machine, then add the Heroku repository:

```

$ heroku git:remote -a bank-api-merayo

```

After committing your changes and pushing it to master, run this command:

```

$ git push heroku master

```

If you added a migration, run the migration in Heroku:

```

$ heroku run "mix ecto.migrate"

```

### Code Status

[![Codeship Status for emerayo/challenge](https://app.codeship.com/projects/3ab3b4a0-483f-0137-a8b9-32f2faa68042/status?branch=master)](https://app.codeship.com/projects/337799)

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/6f23b961ec5c4a06a3667b2c407e0973)](https://www.codacy.com/app/emerayo/challenge?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=emerayo/challenge&amp;utm_campaign=Badge_Grade)

### License

This project is released under the [MIT License](https://opensource.org/licenses/MIT).

### Credits

Made by Emanuel Merayo Goldenberg
