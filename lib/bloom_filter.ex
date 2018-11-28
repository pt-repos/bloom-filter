defmodule BloomFilter do
  def init(expected_size, error_rate) do
    hash_fns = [:sha, :ripemd160, :sha256]
    m = calculate_required_bits(expected_size, error_rate)
    bits = List.duplicate(0, m)
    [bits: bits, length: m, hash_fns: hash_fns]
  end

  def put(filter, items) when is_list(items) do
    Enum.reduce(items, filter, fn item, acc ->
      put(acc, item)
    end)
  end

  def put(filter, item) do
    bits =
      hash(item, filter[:hash_fns], filter[:length])
      |> Enum.reduce(filter[:bits], fn bit_number, bits ->
        List.replace_at(bits, bit_number, 1)
      end)

    Keyword.put(filter, :bits, bits)
  end

  def contains?(filter, items) when is_list(items) do
    Enum.all?(items, fn item -> contains?(filter, item) end)
  end

  def contains?(filter, item) do
    hash(item, filter[:hash_fns], filter[:length])
    |> Enum.all?(fn x -> Enum.at(filter[:bits], x) == 1 end)
  end

  defp calculate_required_bits(expected_size, error_rate) do
    n = expected_size
    p = error_rate
    round(-n * :math.log(p) / :math.pow(:math.log(2), 2))
  end

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
