defmodule Jeaux.Schema do
  def normalize_schema(dict) do
    Enum.reduce(dict, %{}, fn {k,v}, acc ->
      Map.merge(normalize_field({k, v}), acc)
    end)
  end

  defp normalize_field({k, v}) do
    required = String.ends_with?("#{k}", "!")
    name = String.replace_trailing("#{k}", "!", "") |> String.to_atom

    case is_atom(v) do
      true  -> %{name => [type: v, required: required]}
      false -> %{name => [required: required] ++ v}
    end
  end
end
