defmodule Exchat.MessagesRepo do
  use Agent

  def start_link(list \\ []) do
    Agent.start_link(fn -> list end, name: __MODULE__)
  end

  def push(text, user) do
    Agent.update(__MODULE__, fn st -> [%{sender: user, text: text} | st] end)
  end

  def reset() do
    Agent.update(__MODULE__, fn _st -> [] end)
  end

  def take_all do
    Agent.get(__MODULE__, fn st -> Enum.reverse(st) end)
  end
end
