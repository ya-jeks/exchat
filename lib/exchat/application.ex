defmodule Exchat.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Exchat.UsersRepo, []),
      worker(Exchat.MessagesRepo, []),
      worker(Exchat.Bot, []),
      {Plug.Adapters.Cowboy2,
       scheme: :http, plug: nil, options: [port: 4000, dispatch: dispatch()]}
    ]

    opts = [strategy: :one_for_one, name: Exchat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
       [
         {"/ws", Exchat.WsHandler, []},
         {:_, Plug.Adapters.Cowboy2.Handler, {Exchat.Routes, []}}
       ]}
    ]
  end
end
