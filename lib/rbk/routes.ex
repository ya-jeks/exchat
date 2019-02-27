defmodule Rbk.Routes do
  use Plug.Router

  plug(
    Plug.Static,
    at: "/",
    from: "priv/public",
    only: ~w(css fonts images js favicon.ico robots.txt)
  )

  plug(:match)
  plug(:dispatch)

  get "/" do
    ws_host = Application.get_env(:rbk, :ws_host)
    body = EEx.eval_file("priv/public/index.html.eex", ws_host: ws_host)

    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> send_resp(200, body)
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
