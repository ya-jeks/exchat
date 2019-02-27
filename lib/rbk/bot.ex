defmodule Rbk.Bot do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    pid = self()
    user = %Rbk.User{name: "Bot", pid: pid, uid: Rbk.User.uid(pid)}
    Rbk.UsersRepo.push(user)
    speak(user)
    clear_messages()

    {:ok, state}
  end

  def speak(user) do
    text = message()
    Rbk.Chat.broadcast(text, user)
    Rbk.MessagesRepo.push(text, user)
    next_time = (:rand.uniform(10) + 15) * 1000
    Process.send_after(__MODULE__, {:speak, user}, next_time)
  end

  def clear_messages() do
    Rbk.MessagesRepo.reset
    Process.send_after(__MODULE__, {:clear_messages}, 10*60_000)
  end

  def handle_info({:speak, user}, state) do
    speak(user)
    {:noreply, state}
  end

  def handle_info({:clear_messages}, state) do
    clear_messages()
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def message do
    Enum.random([
      "I hope he didn’t die. Unless he left a note naming me his successor, then I hope he did die.",
      "We’re making beer. I’m the brewery!",
      "Well, if jacking on will make strangers think I’m cool, I’ll do it.",
      "I’m so embarrassed. I wish everybody else was dead.",
      "Have you ever tried simply turning off your TV, sitting down with your child, and hitting them?",
      "There. Now no one can say I don’t own John Larroquette’s spine.",
      "Hey sexy mama. Wanna kill all humans?",
      "Blackmail is such an ugly word. I prefer extortion. The ‘x’ makes it sound cool.",
      "I got ants in my butt, and I needs to strut.",
      "Oh, no room for Bender, huh? Fine! I’ll go build my own lunar lander, with blackjack and hookers. In fact, forget the lunar lander and the blackjack. Ahh, screw the whole thing!",
      "That’ll teach those other horses to take drugs.",
      "That’s what they said about being alive!",
      "Game’s over, losers! I have all the money. Compare your lives to mine and then kill yourselves.",
      "Ah, Xmas Eve. Another pointless day where I accomplish nothing.",
      "O’ cruel fate, to be thusly boned! Ask not for whom the bone bones—it bones for thee.",
      "Honey, I wouldn’t talk about taste if I was wearing a lime green tank top.",
      "Hey, whose been messing with my radio? This isn’t alternative rock, it’s college rock",
      "My story is a lot like yours, only more interesting ‘cause it involves robots.",
      "I don’t remember ever fighting Godzilla… But that is so what I would have done!",
      "We’ll soon stage an attack on technology worthy of being chronicled in an anthem by Rush!"
    ])
  end
end
