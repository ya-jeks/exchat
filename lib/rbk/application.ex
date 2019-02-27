defmodule Rbk.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Rbk.UsersRepo, []),
      worker(Rbk.MessagesRepo, []),
      worker(Rbk.Bot, []),
      {Plug.Adapters.Cowboy2,
       scheme: :http, plug: nil, options: [port: 4000, dispatch: dispatch()]}
    ]

    opts = [strategy: :one_for_one, name: Rbk.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
       [
         {"/ws", Rbk.WsHandler, []},
         {:_, Plug.Adapters.Cowboy2.Handler, {Rbk.Routes, []}}
       ]}
    ]
  end
end
