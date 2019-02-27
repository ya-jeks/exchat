defmodule Exchat.User do
  @derive {Poison.Encoder, except: [:pid]}

  @enforce_keys [:name, :pid]
  defstruct [:name, :pid, :uid]

  def uid(pid) do
    str = :erlang.pid_to_list(pid)
    :crypto.hash(:md5, str) |> Base.encode16(case: :lower)
  end
end
