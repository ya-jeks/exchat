defmodule Exchat.WsHandler do
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
    {:ok, user} = Exchat.UsersRepo.lookup(state.pid)
    Exchat.Chat.user_exit(user)
    Exchat.UsersRepo.delete(state.pid)
    :ok
  end

  defp process(%{"event" => "open", "params" => %{"name" => name}}, pid) do
    user = %Exchat.User{name: name, pid: pid, uid: Exchat.User.uid(pid)}
    Exchat.Chat.setup(user)
    Exchat.Chat.joined_user(user)
  end

  defp process(%{"event" => "message", "params" => %{"text" => text}}, pid) do
    {:ok, user} = Exchat.UsersRepo.lookup(pid)
    Exchat.MessagesRepo.push(text, user)
    Exchat.Chat.broadcast(text, user)
  end
end
