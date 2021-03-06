defmodule BloomFilter do
  @moduledoc """
  BloomFilter implementation for quick probabilistic searches.
  The data structure can quickly make a guess whether an item
  probably exists in the set or not, but never gives a false negative.
  """

  @doc """
  Initiates a Bloom Filter, sets the required bit size.
  """
  def init(expected_size, error_rate) do
    hash_fns = [:sha, :ripemd160, :sha256]
    m = calculate_required_bits(expected_size, error_rate)
    bits = List.duplicate(0, m)
    [bits: bits, length: m, hash_fns: hash_fns]
  end

  @doc """
  Puts the given list of items in the filter, i.e. sets the bits corresponding 
  to each item's hash values in the bit array to 1. 
  """
  def put(filter, items) when is_list(items) do
    Enum.reduce(items, filter, fn item, acc ->
      put(acc, item)
    end)
  end

  @doc """
  Puts the given item in the filter ,i.e. sets the bits corresponding 
  to item's hash values in the bit array to 1.
  """
  def put(filter, item) do
    bits =
      hash(item, filter[:hash_fns], filter[:length])
      |> Enum.reduce(filter[:bits], fn bit_number, bits ->
        List.replace_at(bits, bit_number, 1)
      end)

    Keyword.put(filter, :bits, bits)
  end

  @doc """
  Checks whether each item in the given list probably exists in the filter.
  """
  def contains?(filter, items) when is_list(items) do
    Enum.all?(items, fn item -> contains?(filter, item) end)
  end

  @doc """
  Checks whether the given item probably exists in the filter.
  """
  def contains?(filter, item) do
    hash(item, filter[:hash_fns], filter[:length])
    |> Enum.all?(fn x -> Enum.at(filter[:bits], x) == 1 end)
  end

  # Calculates the required size of bit array for the expected filter size and desired error rate.
  defp calculate_required_bits(expected_size, error_rate) do
    n = expected_size
    p = error_rate
    round(-n * :math.log(p) / :math.pow(:math.log(2), 2))
  end

  # Calculates the bits to be set for the given item
  defp hash(item, hash_fns, length) do
    Enum.map(hash_fns, fn hash_fn ->
      hash1 =
        :erlang.phash(item, trunc(:math.pow(2, 32)))
        |> to_string

      :crypto.hash(hash_fn, hash1)
      |> :binary.decode_unsigned()
      |> rem(length)
    end)
  end
end
