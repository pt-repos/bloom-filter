defmodule BloomFilterTest do
  use ExUnit.Case
  doctest BloomFilter

  @size 10
  @error_rate 0.3
  @length 25

  defmodule TestStruct do
    defstruct a: "test", b: 1 
  end

  test "initialize" do
    filter = BloomFilter.init(@size, @error_rate)
    assert !Enum.empty?(filter)
    assert !Enum.empty?(filter[:bits])
    assert filter[:length] == @length
  end

  test "insert an item" do
    filter =
      BloomFilter.init(@size, @error_rate)
      |> BloomFilter.put("test")

    assert BloomFilter.contains?(filter, "test")
  end

  test "insert a list" do
    data = ["test", "test2", "test3", "test4"]

    filter =
      BloomFilter.init(@size, @error_rate)
      |> BloomFilter.put(data)

    assert BloomFilter.contains?(filter, data)
  end

  test "insert a struct" do
    struct = %TestStruct{}

    filter =
      BloomFilter.init(@size, @error_rate)
      |> BloomFilter.put(struct)

    assert BloomFilter.contains?(filter, struct)
  end

  describe "contains? negative cases" do
    test "doesn't contain item" do
      filter =
        BloomFilter.init(@size, @error_rate)
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
        BloomFilter.init(@size, @error_rate)
        |> BloomFilter.put(data)

      assert !BloomFilter.contains?(filter, check)
    end

    test "doesn't contain all the members of list" do
      data = [1, 2, 3, 4]
      check = [5, 6, 7, 8]

      filter =
        BloomFilter.init(@size, @error_rate)
        |> BloomFilter.put(data)

      assert !BloomFilter.contains?(filter, check)
    end
  end

  test "error rate" do
    filter_params = [{200, 0.2}, {100, 0.05}, {50, 0.1}]
    
    Enum.each(filter_params, fn {size, rate} -> 

      filter = BloomFilter.init(size, rate)

      data = Enum.map(1..size, fn _i -> :rand.uniform(10_000) end)
      filter = BloomFilter.put(filter, data)
      
      error = 
      Enum.reduce(1..size*100, 0, fn _i, error ->
        n = :rand.uniform(10_000) 

        if BloomFilter.contains?(filter, n) and !Enum.member?(data, n), 
        do: error + 1,
        else:  error
      end)

      assert Float.floor(error/(size*100), 1) <= rate
    end)
  end
end