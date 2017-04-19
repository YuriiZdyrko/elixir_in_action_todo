# Todo

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `todo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:todo, "~> 0.1.0"}]
end
```

## Run

iex --sname node1@localhost -S mix
iex --erl "-todo port 5555" --sname node2@localhost -S mix

http://localhost:5454/add_entry?list=girls_list&date=20131219&title=Weirdo2
http://localhost:5454/entries?list=girls_list&date=20131219
http://localhost:5555/entries?list=girls_list&date=20131219
