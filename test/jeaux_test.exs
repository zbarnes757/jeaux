defmodule JeauxTest do
  use ExUnit.Case
  doctest Jeaux

  test "applies defaults to params" do
    params = %{}
    schema = %{foo: [default: "bar"]}

    {status, result} = Jeaux.validate(params, schema)

    assert status === :ok
    assert result[:foo] === "bar"
  end

  test "does not apply defaults when param is present" do
    params = %{"limit" => "2", "sort_by" => "name", "sort_dir" => "asc"}
    schema = %{
      limit: [type: :integer, default: 10, min: 1, max: 100],
      offset: [type: :integer, default: 0, min: 0],
      sort_by: [type: :string, default: "created_at"],
      sort_dir: [type: :string, default: "asc"]
    }

    {status, result} = Jeaux.validate(params, schema)

    assert status === :ok
    assert result[:sort_by] === "name"
  end

  test "throws error when required params not present" do
    params = %{}
    schema = %{foo!: :string}

    {status, message} = Jeaux.validate(params, schema)

    assert status === :error
    assert message === "foo is required."
  end

  test "returns params when required params present" do
    params = %{foo: "bar"}
    schema = %{foo!: :string}

    {status, result} = Jeaux.validate(params, schema)

    assert status === :ok
    assert result[:foo] === "bar"
  end

  test "converts param to string when able" do
    params = %{foo: 1}
    schema = %{foo!: :string}

    {status, result} = Jeaux.validate(params, schema)

    assert status === :ok
    assert result[:foo] === "1"
  end

  test "converts integer param to float when able" do
    params = %{foo: 1}
    schema = %{foo!: :float}

    {status, result} = Jeaux.validate(params, schema)

    assert status === :ok
    assert result[:foo] === 1.0
  end

  test "converts string param to float when able" do
    params = %{foo: "1.0"}
    schema = %{foo!: :float}

    {status, result} = Jeaux.validate(params, schema)

    assert status === :ok
    assert result[:foo] === 1.0
  end

  test "throws error when param should be float but isn't" do
    params = %{foo: "cat"}
    schema = %{foo!: :float}

    {status, message} = Jeaux.validate(params, schema)

    assert status === :error
    assert message === "foo must be a float."
  end

  test "converts float param to integer when able" do
    params = %{foo: 1.0}
    schema = %{foo!: :integer}

    {status, result} = Jeaux.validate(params, schema)

    assert status === :ok
    assert result[:foo] === 1
  end

  test "throws error when param should be integer but isn't" do
    params = %{foo: "bar"}
    schema = %{foo!: :integer}

    {status, message} = Jeaux.validate(params, schema)

    assert status === :error
    assert message === "foo must be an integer."
  end

  test "throws error when param is less than min limit" do
    params = %{foo: 1}
    schema = %{foo!: [type: :integer, min: 2]}

    {status, message} = Jeaux.validate(params, schema)

    assert status === :error
    assert message === "foo must be greater than or equal to 2"
  end

  test "throws error when param is more than max limit" do
    params = %{foo: 2}
    schema = %{foo!: [type: :integer, max: 1]}

    {status, message} = Jeaux.validate(params, schema)

    assert status === :error
    assert message === "foo must be less than or equal to 1"
  end

  test "throws error when param is not in schema" do
    params = %{foo: 1, bar: "not in schema"}
    schema = %{foo!: [type: :integer, max: 1]}

    {status, message} = Jeaux.validate(params, schema)

    assert status === :error
    assert message === "bar is not a valid parameter"
  end

  test "works with strings as map keys" do
    params = %{"id" => "an-id", "radius" => "100"}
    schema = %{
      "id!"     => :string,
      "radius"  => [type: :integer, default: 100, min: 1, max: 100]
    }

    {status, result} = Jeaux.validate(params, schema)

    assert status          === :ok
    assert result[:id]    === "an-id"
    assert result[:radius] === 100
  end

  test "works with multiple params" do
    params = %{lat: 0.0, lon: 0.0}
    schema = %{lat!: :float, lon!: :float, radius: [type: :integer, default: 100, min: 1, max: 100]}

    {status, result} = Jeaux.validate(params, schema)

    assert status          === :ok
    assert result[:lat]    === 0.0
    assert result[:lon]    === 0.0
    assert result[:radius] === 100
  end

  test "makes sure a value is valid" do
    params = %{foo: 1}
    schema = %{foo!: [type: :integer, valid: 1]}

    {status, result} = Jeaux.validate(params, schema)

    assert status === :ok
    assert result[:foo] === 1
  end

  test "makes sure a value is valid with a list of options" do
    params = %{foo: 1}
    schema = %{foo!: [type: :integer, valid: [1, 2]]}

    {status, result} = Jeaux.validate(params, schema)

    assert status === :ok
    assert result[:foo] === 1
  end

  test "throws error when param is not a valid value" do
    params = %{foo: 1}
    schema = %{foo!: [type: :integer, valid: 2]}

    {status, message} = Jeaux.validate(params, schema)

    assert status === :error
    assert message === "foo is not a valid value."
  end

  test "throws error when param is not a valid value with a list of valids" do
    params = %{foo: 1}
    schema = %{foo!: [type: :integer, valid: [2, 3]]}

    {status, message} = Jeaux.validate(params, schema)

    assert status === :error
    assert message === "foo is not a valid value."
  end

  test "handles nested schema validation" do
    params = %{
      "type" => "Feature",
      "geometry" => %{
        "type" => "Point",
        "coordinates" => [125.6, 10.1]
      },
      "properties" => %{
        "name": "Dinagat Islands"
      }
    }

    schema = %{
      type!: :string,
      geometry: %{
        type!: :string,
        coordinates: :list
      },
      properties: %{
        name: :string
      }
    }

    {status, result} = Jeaux.validate(params, schema)

    assert status === :ok
    assert result[:geometry][:type] === "Point"
  end

  test "handles errors in nested schema validation" do
    params = %{
      "type" => "Feature",
      "geometry" => %{
        "type" => "Point",
        "coordinates" => 90.0
      },
      "properties" => %{
        "name": "Dinagat Islands"
      }
    }

    schema = %{
      type!: :string,
      geometry: %{
        type!: :string,
        coordinates: :list
      },
      properties: %{
        name: :string
      }
    }

    {status, message} = Jeaux.validate(params, schema)

    assert status === :error
    assert message === "coordinates must be a list."
  end

  test "coerces a query string array into list type" do
    params = %{"array" => "-96.7915,32.78,-96.785,32.783"}
    schema = %{array!: :list}

    {status, result} = Jeaux.validate(params, schema)

    assert status === :ok
    assert result[:array] === ["-96.7915", "32.78", "-96.785", "32.783"]
  end

  test "asserts a value is a valid guid" do
    params = %{foo: "0e14f2db-ff0b-43bd-b88c-01b9f226778f"}
    schema = %{foo!: :guid}

    {status, result} = Jeaux.validate(params, schema)

    assert status === :ok
    assert result[:foo] === "0e14f2db-ff0b-43bd-b88c-01b9f226778f"

    params2 = %{foo: "{D1A5279D-B27D-4CD4-A05E-EFDD53D08E8D}"}

    {status, result} = Jeaux.validate(params2, schema)

    assert status === :ok
    assert result[:foo] === "{D1A5279D-B27D-4CD4-A05E-EFDD53D08E8D}"
  end

  test "throws an error when a value is not a valid guid" do
    params = %{foo: "some-string"}
    schema = %{foo!: :guid}

    {status, message} = Jeaux.validate(params, schema)

    assert status === :error
    assert message === "foo must be in valid guid format."
  end

  test "applies defaults when value is nil" do
    params = %{foo: nil}
    schema = %{foo: [default: "bar"]}

    {status, result} = Jeaux.validate(params, schema)

    assert status === :ok
    assert result[:foo] === "bar"
  end

  test "accepts boolean types" do
    params = %{foo: true}
    schema = %{foo: :boolean}

    {status, result} = Jeaux.validate(params, schema)

    assert status === :ok
    assert result[:foo] === true
  end

  test "coerces boolean types if in schema" do
    params = %{foo: "true"}
    schema = %{foo: :boolean}

    {status, result} = Jeaux.validate(params, schema)

    assert status === :ok
    assert result[:foo] === true
  end

  test "throws error if not a boolean" do
    params = %{foo: 123}
    schema = %{foo: :boolean}

    {status, message} = Jeaux.validate(params, schema)

    assert status === :error
    assert message === "foo must be a boolean."
  end

  test "accepts camelCase params and converts to snake_case" do
    params = %{"limit" => "2", "sortBy" => "name", "sortDir" => "asc"}
    schema = %{
      limit: [type: :integer, default: 10, min: 1, max: 100],
      offset: [type: :integer, default: 0, min: 0],
      sort_by: [type: :string, default: "created_at"],
      sort_dir: [type: :string, default: "asc"]
    }

    {status, result} = Jeaux.validate(params, schema)

    assert status === :ok
    assert result === %{limit: 2, offset: 0, sort_by: "name", sort_dir: "asc"}
  end
end
