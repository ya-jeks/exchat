defmodule Rbk.UsersRepo do
  use GenServer
  alias Rbk.User

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    :ets.new(__MODULE__, [:set, :public, :named_table])
    {:ok, state}
  end

  def lookup(pid) do
    case GenServer.call(__MODULE__, {:lookup, pid}) do
      [{_id, user}] -> {:ok, user}
      [] -> {:error, :empty}
    end
  end

  def delete(pid) do
    GenServer.call(__MODULE__, {:delete, pid})
  end

  def take_all do
    :ets.match_object(__MODULE__, {:_, :_})
    |> Enum.map(fn {_pid, user} -> user end)
  end

  def push(%User{} = user) do
    GenServer.call(__MODULE__, {:push, user})
  end

  def handle_call({:lookup, pid}, _from, state) do
    result = :ets.lookup(__MODULE__, pid)
    {:reply, result, state}
  end

  def handle_call({:delete, pid}, _from, state) do
    result = :ets.delete(__MODULE__, pid)
    {:reply, result, state}
  end

  def handle_call({:push, %User{pid: pid} = user}, _from, state) do
    true = :ets.insert(__MODULE__, {pid, user})
    {:reply, user, state}
  end
end
