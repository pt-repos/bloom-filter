defmodule BloomFilter do
  def init(expected_size, false_positive_rate) do
    # n = expected_size
    # p = false_positive_rate
    hash_fns = [:sha, :ripemd160, :sha256]
    m = calculate_required_bits(expected_size, false_positive_rate)
    bits = List.duplicate(0, m)
    [bits: bits, length: m, hash_fns: hash_fns]
  end

  def put(filter, item) do
    bits =
      hash(item, filter[:hash_fns], filter[:length])
      |> Enum.reduce(filter[:bits], fn bit_number, bits ->
        List.replace_at(bits, bit_number, 1)
      end)

    Keyword.put(filter, :bits, bits)
  end

  def contains?(filter, item) do
    hash(item, filter[:hash_fns], filter[:length])
    |> Enum.all?(fn x -> Enum.at(filter[:bits], x) == 1 end)
  end

  defp calculate_required_bits(expected_size, false_positive_rate) do
    n = expected_size
    p = false_positive_rate
    round(-n * :math.log(p) / :math.pow(:math.log(2), 2))
  end

  defp hash(item, hash_fns, length) do
    Enum.map(hash_fns, fn hash_fn ->
      :crypto.hash(hash_fn, item)
      |> :binary.decode_unsigned()
      |> rem(length)
    end)
  end
end
