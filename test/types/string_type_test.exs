defmodule Talos.Types.StringTypeTest do
  use ExUnit.Case
  alias Talos.Types.StringType

  test "#valid? - with regexp" do
    assert true == StringType.valid?(%StringType{regexp: ~r/\d/}, "1")
    assert false == StringType.valid?(%StringType{regexp: ~r/^\d\Z/}, "1000")
    assert false == StringType.valid?(%StringType{regexp: ~r/^\d\Z/}, 1)
    assert false == StringType.valid?(%StringType{regexp: ~r/^\d\Z/}, 1.0)
    assert false == StringType.valid?(%StringType{regexp: ~r/^\d\Z/}, %{})
    assert false == StringType.valid?(%StringType{regexp: ~r/^\d\Z/}, nil)
    assert false == StringType.valid?(%StringType{regexp: ~r/^\d\Z/}, [])
    assert true == StringType.valid?(%StringType{regexp: ~r/^\d{4}-\d{2}-\d{2}\Z/}, "2019-22-13")
  end

  test "#valid? - without regexp" do
    assert false == StringType.valid?(%StringType{}, 1.0)
    assert false == StringType.valid?(%StringType{}, 1)
    assert true == StringType.valid?(%StringType{}, "String")
    assert false == StringType.valid?(%StringType{}, %{})
    assert false == StringType.valid?(%StringType{}, nil)
    assert false == StringType.valid?(%StringType{}, DateTime.utc_now())
    assert false == StringType.valid?(%StringType{}, [])
  end

  test "#valid? - other params" do
    assert true == StringType.valid?(%StringType{length: 6}, "String")
    assert false == StringType.valid?(%StringType{length: 7}, "String")
    assert true == StringType.valid?(%StringType{max_length: 10}, "String")
    assert false == StringType.valid?(%StringType{max_length: 3}, "String")
    assert true == StringType.valid?(%StringType{min_length: 3}, "String")
    assert false == StringType.valid?(%StringType{min_length: 3}, "")
    assert true == StringType.valid?(%StringType{min_length: 0}, "")
  end
end