defmodule BloomFilterTest do
  use ExUnit.Case
  doctest BloomFilter

  @size 10
  @rate 0.3
  @length 25

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

  describe "contains? negative cases" do
    test "doesn't contain item" do
      filter =
        BloomFilter.init(@size, @rate)
        |> BloomFilter.put("test")

      assert !BloomFilter.contains?(filter, "not in filter")
    end

    test "doesn't contain any member of list" do
      data = ["test", "test2", "test3", "test4"]
      check = ["csc", "scjsk", "zxczxcxz", "ajcbasnkan"]

      filter = 
        BloomFilter.init(@size, @rate)
        |> BloomFilter.put(data)

      assert !BloomFilter.contains?(filter, check)
    end

    test "doesn't contain all the members of list" do
      data = ["test", "test2", "test3", "test4"]
      check = ["csc", "test2", "zxczxcxz", "test4"]

      filter = 
        BloomFilter.init(@size, @rate)
        |> BloomFilter.put(data)

      assert !BloomFilter.contains?(filter, check)
    end
  end
end
