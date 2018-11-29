# BloomFilter

**TODO: Add description**
Elixir implementation of Bloom Filter for quick probabilistic searches.
The data structure can quickly make a guess whether an item probably exists in the set or not.
Result may be a false positive but it is never a false negative. The probability of getting a false positive can be controlled by selecting sufficient size of bit array.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `bloom_filter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bloom_filter, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/bloom_filter](https://hexdocs.pm/bloom_filter).

