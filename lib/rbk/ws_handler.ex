defmodule Rbk.WsHandler do
  @behaviour :cowboy_websocket
  require Logger

  def init(%{pid: pid} = req, _opts) do
    {:cowboy_websocket, req, %{pid: pid}, %{idle_timeout: 30000}}
  end

  def websocket_handle({:text, "ping"}, state) do
    {:reply, {:text, "pong"}, state}
  end

  def websocket_handle({:text, text}, state) do
    case Poison.decode(text) do
      {:ok, json} -> process(json, state.pid)
      {:error, err} -> Logger.debug(inspect(err))
    end

    {:ok, state}
  end

  def websocket_info({:text, msg}, state) do
    {:reply, {:text, msg}, state}
  end

  def terminate(_, _, state) do
    {:ok, user} = Rbk.UsersRepo.lookup(state.pid)
    Rbk.Chat.user_exit(user)
    Rbk.UsersRepo.delete(state.pid)
    :ok
  end

  defp process(%{"event" => "open", "params" => %{"name" => name}}, pid) do
    user = %Rbk.User{name: name, pid: pid, uid: Rbk.User.uid(pid)}
    Rbk.Chat.setup(user)
    Rbk.Chat.joined_user(user)
  end

  defp process(%{"event" => "message", "params" => %{"text" => text}}, pid) do
    {:ok, user} = Rbk.UsersRepo.lookup(pid)
    Rbk.MessagesRepo.push(text, user)
    Rbk.Chat.broadcast(text, user)
  end
end
