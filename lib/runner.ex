defmodule Runner do
  alias Todo.Cache
  alias Todo.Server

  @first_list "dudes_list"
  @second_list "girls_list"
  @third_list "xyz_list"

  def run1(name \\ @first_list) do
    pid = Cache.server_process(name)
    Server.add_entry(
      pid,
      %{date: {2013, 12, 19}, title: "Dentist"}
    )
    IO.inspect (Server.entries(pid, {2013, 12, 19}))
  end

  def run2(name \\ @second_list) do
    pid = Cache.server_process(name)
    Server.add_entry(
      pid,
      %{date: {2013, 12, 19}, title: "Girl"}
    )
    IO.inspect(Server.entries(pid, {2013, 12, 19}))
  end

  def run3(name \\ @third_list) do
    pid = Cache.server_process(name)
    Server.add_entry(
      pid,
      %{date: {2013, 12, 19}, title: "XYZ"}
    )
    IO.inspect(Server.entries(pid, {2013, 12, 19}))
  end

  def run do
    Todo.CacheSupervisor.start_link
    run1()
    run2()
    run3()
    nil
  end
end
