defmodule Jeaux do
  @moduledoc """
  This is the main and only access point for the module.
  """
  alias Jeaux.Params
  alias Jeaux.Schema

  @doc """
  Validates a map against a schema.

  returns `{:ok, validated_params}` or `{:error, error_message}`

  for example:
  ```elixir
  params = %{"limit" => "2", "sort_by" => "name", "sort_dir" => "asc"}
  schema = %{
    limit: [type: :integer, default: 10, min: 1, max: 100],
    offset: [type: :integer, default: 0, min: 0],
    sort_by: [type: :string, default: "created_at"],
    sort_dir: [type: :string, default: "asc"]
  }

  {:ok, valid_params} = Jeaux.validate(params, schema)
  ```
  """
  def validate(params, schema), do: Params.compare(params, Schema.normalize_schema(schema))
end
