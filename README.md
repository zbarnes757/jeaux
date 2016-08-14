# Jeaux

[![Hex.pm](https://img.shields.io/hexpm/v/jeaux.svg)](https://hex.pm/packages/jeaux)
[![Build Status](https://travis-ci.org/zbarnes757/jeaux.svg?branch=master)](https://travis-ci.org/zbarnes757/jeaux)
[![Coverage Status](https://coveralls.io/repos/github/zbarnes757/jeaux/badge.svg?branch=)](https://coveralls.io/github/zbarnes757/jeaux?branch=)

Jeaux is my attempt at building a light and easy schema validator.

## Installation

[Available in Hex](https://hex.pm/packages/jeaux), the package can be installed as:

  1. Add `jeaux` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:jeaux, "~> 0.1.0"}]
    end
    ```

Right now it only supports validating params but I would like to be able to deep validate payloads as well.

Example:

```elixir
# web/controllers/my_controller.ex
@params_schema %{
  lat!: :float,
  lon!: :float,
  radius: [type: :integer, default: 100, min: 1, max: 100]
}

def index(conn, params) do
    case Jeaux.validate(params, @params_schema) do
      {:ok, valid_params} -> do_your_thing(valid_params)
      {:error, message} -> Explode.bad_request(conn, message)
    end
end
```

Using a `!` in your key denotes it is required.

Currently, the following keys are valid:
* `type:` with `:integer`, `:string`, or `:float` as applicable types
* `default:` Sets a default value if none is currently provided in params
* `min:` Minimum value a param can have
* `max:` Maximum value a param can have

It is important to note that no matter how params are passed in to Jeaux, they will be returned with keys as atoms.

If you want to contribute, feel free to fork and open a pr.

Checkout [Explode](https://github.com/pkinney/explode) for an easy utility for responding with standard HTTP/JSON error payloads in Plug- and Phoenix-based applications.
