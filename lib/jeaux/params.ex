defmodule Jeaux.Params do
  def compare(params, schema) do
    params
    |> apply_defaults(schema)
    |> validate_required(schema)
    |> validate_types(schema)
    |> validate_min(schema)
    |> validate_max(schema)
  end

  defp apply_defaults(params, schema) do
    param_keys = Map.keys(params)

    default_schema_keys =
      schema
      |> Enum.filter(fn({_k, v}) -> Keyword.get(v, :default) !== nil end)
      |> Keyword.keys
      |> Enum.drop_while(fn(default) -> Enum.member?(param_keys, default) end)


    add_defaults(params, schema, default_schema_keys)
  end

  defp validate_required(params, schema) do
    param_keys = Map.keys(params)

    compared_params =
      schema
      |> Enum.filter(fn({_k, v}) -> Keyword.get(v, :required) === true end)
      |> Keyword.keys
      |> Enum.drop_while(fn(required_param) -> Enum.member?(param_keys, required_param) end)

    case Enum.empty?(compared_params) do
      true  -> {:ok, params}
      false ->
        [first_required_param | _tail ] = compared_params
        {:error, "#{first_required_param} is required."}
    end
  end

  defp validate_types({:error, message}, _schema), do: {:error, message}
  defp validate_types({:ok, params}, schema) do
    errors = Enum.reduce params, [], fn {k, v}, error_list  ->
      type = Keyword.get(schema[k] || [], :type)

      validate_type({k, v}, schema[k], type) ++ error_list
    end

    case Enum.empty?(errors) do
      true  -> {:ok, params}
      false ->
        [first_error | _tail ] = errors
        first_error
    end
  end

  defp validate_min({:error, message}, _schema), do: {:error, message}
  defp validate_min({:ok, params}, schema) do
    minimum_schema_keys =
      schema
      |> Enum.filter(fn({_k, v}) -> Keyword.get(v, :min) !== nil end)
      |> Keyword.keys

    errors = Enum.reduce minimum_schema_keys, [], fn k, error_list  ->
      minimum = Keyword.get(schema[k], :min)

      case params[k] >= minimum do
        true  -> [] ++ error_list
        false -> [{:error, "#{k} must be greater than or equal to #{minimum}"}] ++ error_list
      end
    end

    case Enum.empty?(errors) do
      true  -> {:ok, params}
      false ->
        [first_error | _tail ] = errors
        first_error
    end
  end

  defp validate_max({:error, message}, _schema), do: {:error, message}
  defp validate_max({:ok, params}, schema) do
    maximum_schema_keys =
      schema
      |> Enum.filter(fn({_k, v}) -> Keyword.get(v, :max) !== nil end)
      |> Keyword.keys

    errors = Enum.reduce maximum_schema_keys, [], fn k, error_list  ->
      maximum = Keyword.get(schema[k], :max)

      case params[k] <= maximum do
        true  -> [] ++ error_list
        false -> [{:error, "#{k} must be less than or equal to #{maximum}"}] ++ error_list
      end
    end

    case Enum.empty?(errors) do
      true  -> {:ok, params}
      false ->
        [first_error | _tail ] = errors
        first_error
    end
  end

  defp validate_type(_param, _schema, nil), do: []
  defp validate_type({k, _v}, nil, _type), do: [{:error, "#{k} is not a valid parameter"}]
  defp validate_type({k, v}, _schema, type) when type === :integer do
    case is_integer(v) do
      true  -> []
      false -> [{:error, "#{k} must be an integer."}]
    end
  end

  defp validate_type({k, v}, _schema, type) when type === :float do
    case is_float(v) do
      true  -> []
      false -> [{:error, "#{k} must be a float."}]
    end
  end

  defp validate_type({k, v}, _schema, type) when type === :string do
    case is_binary(v) do
      true  -> []
      false -> [{:error, "#{k} must be a string."}]
    end
  end

  defp add_defaults(params, _schema, []), do: params
  defp add_defaults(params, schema, [k | tail]) do
    default = Keyword.get(schema[k], :default)

    Map.put(add_defaults(params, schema, tail), k, default)
  end
end
