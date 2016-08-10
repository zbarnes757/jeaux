defmodule Jeaux do
  alias Jeaux.Params
  alias Jeaux.Schema

  def validate(params, schema), do: Params.compare(params, Schema.normalize_schema(schema))
end
