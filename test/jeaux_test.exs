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

  test "converts param to float when able" do
    params = %{foo: 1}
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
end
