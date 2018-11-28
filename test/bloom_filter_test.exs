defmodule BloomFilterTest do
  use ExUnit.Case
  doctest BloomFilter

  @size 10
  @rate 0.3
  @length 25

  defmodule TestStruct do
    defstruct a: "test", b: 1 
  end

  test "initialize" do
    filter = BloomFilter.init(@size, @rate)
    assert !Enum.empty?(filter)
    assert !Enum.empty?(filter[:bits])
    assert filter[:length] == @length
  end

  test "insert an item" do
    filter =
      BloomFilter.init(@size, @rate)
      |> BloomFilter.put("test")

    assert BloomFilter.contains?(filter, "test")
  end

  test "insert a list" do
    list = ["test", "test2", "test3", "test4"]

    filter =
      BloomFilter.init(@size, @rate)
      |> BloomFilter.put(list)

    assert BloomFilter.contains?(filter, list)
  end

  test "insert a struct" do
    struct = %TestStruct{}

    filter =
      BloomFilter.init(@size, @rate)
      |> BloomFilter.put(struct)

    assert BloomFilter.contains?(filter, struct)
  end

  describe "contains? negative cases" do
    test "doesn't contain item" do
      filter =
        BloomFilter.init(@size, @rate)
        |> BloomFilter.put("test")

      assert !BloomFilter.contains?(filter, "not in filter")
    end

    test "doesn't contain any member of list" do
      
      data1 = %TestStruct{}
      data2 = %TestStruct{b: 2}
      data3 = %TestStruct{a: "data3"}
      data4 = %TestStruct{a: "data4", b: 4}

      data = [data1, data2, data3, data4]
      check = [data1, data2, %TestStruct{a: "test", b: 3}, data4]

      filter =
        BloomFilter.init(@size, @rate)
        |> BloomFilter.put(data)

      assert !BloomFilter.contains?(filter, check)
    end

    test "doesn't contain all the members of list" do
      data = [1, 2, 3, 4]
      check = [5, 6, 7, 8]

      filter =
        BloomFilter.init(@size, @rate)
        |> BloomFilter.put(data)

      assert !BloomFilter.contains?(filter, check)
    end
  end
end