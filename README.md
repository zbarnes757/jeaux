# Jeaux

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
def index(conn, %{"lon" => lon, "lat" => lat} = params) do
    case Jeaux.validate(params, %{lat!: :float, lon!: :float, radius: [field: :integer, default: 100, min: 1, max: 100]}) do
      {:ok, valid_params} -> do_your_thing(valid_params)
      {:error, message} -> Explode.bad_request(conn, message)
    end
end
```

Using a `!` in your key denotes it is required.

Currently only validates presence, type (and only strings, floats, and integers), min, max, and adds defaults.

If you want to contribute, feel free to fork and open a pr.

Checkout [Explode](https://github.com/pkinney/explode) for an easy utility for responding with standard HTTP/JSON error payloads in Plug- and Phoenix-based applications.
