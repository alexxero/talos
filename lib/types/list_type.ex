defmodule Talos.Types.ListType do
  @moduledoc """
    ListType is used to check passed value is a list

  ```elixir
    iex> import Talos
    iex> Talos.valid?(list(allow_blank: true), [])
    true
    iex> Talos.valid?(list(allow_nil: true), nil)
    true
    iex> Talos.valid?(list(), nil)
    false
    iex> Talos.valid?(list(), ["one", two, 3, %{}])
    true
    iex> Talos.valid?(list(type: integer()), ["one", two, 3, %{}])
    false
    iex> Talos.valid?(list(type: integer()), [1,2,3])
    true
    iex> Talos.valid?(list(type: integer(allow_nil: true)), [nil,2,3])
    true

  ```

  Additional parameters:

  `allow_blank` - allows array to be empty

  `allow_nil` - allows value to be nil

  `type` - defines type of array elements

  """
  defstruct [
    :type,
    allow_nil: false,
    allow_blank: true,
    example_value: nil,
    min_length: nil,
    max_length: nil
  ]

  @behaviour Talos.Types
  @type t :: %{
          __struct__: atom,
          type: struct | module | nil,
          allow_blank: boolean,
          allow_nil: boolean,
          example_value: any
        }
  @spec valid?(Talos.Types.ListType.t(), any) :: boolean
  def valid?(module, value) do
    errors(module, value) == []
  end

  @spec errors(Talos.Types.ListType.t(), any) :: list(String.t())
  def errors(%__MODULE__{allow_blank: true}, []), do: []
  def errors(%__MODULE__{allow_blank: false}, []), do: ["list should not be empty"]
  def errors(%__MODULE__{allow_nil: true}, nil), do: []
  def errors(%__MODULE__{allow_nil: false}, nil), do: ["list should be set"]

  def errors(
        %__MODULE__{type: element_type, min_length: min_len, max_length: max_len} = _array_type,
        values
      ) do
    case is_list(values) do
      true ->
        length_errors =
          cond do
            !is_nil(min_len) && length(values) < min_len ->
              ["List length should be greater than #{min_len}"]

            !is_nil(max_len) && length(values) > max_len ->
              ["List length should be lower than #{max_len}"]

            true ->
              []
          end

        length_errors ++ return_only_errors(element_type, values)

      false ->
        [inspect(values), "should be ListType"]
    end
  end

  @spec permit(Talos.Types.ListType.t(), any) :: any
  def permit(%__MODULE__{allow_nil: true}, nil) do
    nil
  end

  def permit(%__MODULE__{type: type}, list) do
    case is_nil(type) do
      true -> list
      false -> Enum.map(list, fn el -> Talos.permit(type, el) end)
    end
  end

  defp return_only_errors(element_type, values) do
    values
    |> Enum.map(fn val -> element_errors(element_type, val) end)
    |> Enum.reject(fn element -> element in [%{}, []] end)
  end

  defp element_errors(nil = _type_description, _value) do
    []
  end

  defp element_errors(type_description, value) do
    Talos.errors(type_description, value)
  end
end
