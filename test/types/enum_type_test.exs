defmodule Talos.Types.EnumTypeTest do
  use ExUnit.Case
  alias Talos.Types.EnumType
  alias Talos.Types.IntegerType
  alias Talos.Types.StringType
  alias Talos.Types.FloatType
  doctest EnumType

  test "#valid?" do
    assert true == EnumType.valid?(%EnumType{members: [1, 2, 3, 4, 5]}, 5)
    assert false == EnumType.valid?(%EnumType{members: [1, 2, 3, 4, 5]}, 0)
    assert false == EnumType.valid?(%EnumType{members: [1, 2, 3, 4, 5], allow_nil: true}, 0)
    assert true == EnumType.valid?(%EnumType{members: [1, 2, 3, 4, 5], allow_nil: true}, nil)
    assert true == EnumType.valid?(%EnumType{members: ["a", "b", "c", "d", "e"]}, "e")
    assert false == EnumType.valid?(%EnumType{members: ["a", "b", "c", "d", "e"]}, "z")

    assert true ==
             EnumType.valid?(
               %EnumType{members: [%StringType{}, %IntegerType{}]},
               "ab572080-f3f8-4046-a81a-17a35382e151"
             )
  end

  test "#valid? check if types passed" do
    assert true ==
             EnumType.valid?(%EnumType{members: [%IntegerType{}, %FloatType{}, "lul"]}, "lul")

    assert true == EnumType.valid?(%EnumType{members: [%IntegerType{}, %FloatType{}, "lul"]}, 1)
    assert true == EnumType.valid?(%EnumType{members: [%IntegerType{}, %FloatType{}, "lul"]}, 1.0)

    assert true == EnumType.valid?(%EnumType{members: [%IntegerType{}, %StringType{}]}, 10)
    assert true == EnumType.valid?(%EnumType{members: [%StringType{}, %IntegerType{}]}, 10)
    assert true == EnumType.valid?(%EnumType{members: [%IntegerType{}, %StringType{}]}, "abc")
    assert true == EnumType.valid?(%EnumType{members: [%StringType{}, %IntegerType{}]}, "abc")

    assert false ==
             EnumType.valid?(%EnumType{members: [%IntegerType{}, %FloatType{}, "lul"]}, "lol")
  end

  test "errors - returns list with error element" do
    assert [] == EnumType.errors(%EnumType{members: [1, 2, 3, 4, 5]}, 5)

    assert [_error1, _error2, _error3, _error4, _error5] =
             EnumType.errors(%EnumType{members: [1, 2, 3, 4, 5]}, 0)

    assert [] == EnumType.errors(%EnumType{members: ["a", "b", "c", "d", "e"]}, "e")

    assert errors = EnumType.errors(%EnumType{members: ["a", "b", "c", "d", "e"]}, "z")

    assert [] ==
             EnumType.errors(
               %EnumType{members: [%StringType{}, %IntegerType{}]},
               "ab572080-f3f8-4046-a81a-17a35382e151"
             )
  end

  test "#valid? - call with invalid members value" do
    assert_raise FunctionClauseError, fn ->
      EnumType.valid?(%EnumType{members: nil}, "SomeVal")
    end

    assert_raise FunctionClauseError, fn -> EnumType.valid?(%EnumType{members: 1}, "SomeVal") end

    assert_raise FunctionClauseError, fn ->
      EnumType.valid?(%EnumType{members: %{}}, "SomeVal")
    end
  end
end
