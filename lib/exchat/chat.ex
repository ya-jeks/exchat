defmodule Exchat.Chat do
  def setup(user) do
    Exchat.UsersRepo.push(user)

    users = Exchat.UsersRepo.take_all()
    messages = Exchat.MessagesRepo.take_all()
    params = %{uid: user.uid, users: users, messages: messages}

    send_message(user, %{type: "setup", params: params})
  end

  def broadcast(text, sender) do
    msg = %{type: "message", params: %{sender: sender, text: text}}

    Exchat.UsersRepo.take_all()
    |> Enum.map(fn user -> send_message(user, msg) end)
  end

  def joined_user(user) do
    msg = %{type: "joined_user", params: %{user: user}}

    Exchat.UsersRepo.take_all()
    |> Enum.map(fn u -> send_message(u, msg) end)
  end

  def user_exit(user) do
    msg = %{type: "user_exit", params: %{user: user}}

    Exchat.UsersRepo.take_all()
    |> Enum.map(fn u -> send_message(u, msg) end)
  end

  defp send_message(recipient, data) do
    text =
      case Poison.encode(data) do
        {:ok, msg} -> msg
        {:error, err} -> IO.puts(inspect([:err, err]))
      end

    send(recipient.pid, {:text, text})
  end
end
