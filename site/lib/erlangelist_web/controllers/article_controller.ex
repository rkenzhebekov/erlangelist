defmodule ErlangelistWeb.ArticleController do
  use ErlangelistWeb, :controller

  alias Erlangelist.Article

  def most_recent(conn, _params) do
    render_article(conn, Article.most_recent())
  end

  def article(conn, %{"article_id" => article_id}) do
    case Article.article(Article.id_from_string(article_id)) do
      %{has_content?: true} = article ->
        conn
        |> assign(:title_suffix, article.short_title)
        |> render_article(article)

      _ ->
        not_found(conn)
    end
  end

  def article(conn, _params), do: not_found(conn)

  def article_from_old_path(%{private: %{article: article}} = conn, _params) do
    conn
    |> put_layout(false)
    |> redirect(external: "/article/#{article.id}")
  end

  defp render_article(conn, article) do
    Erlangelist.UsageStats.report(:article, article.id)
    render(conn, "article.html", %{article: article})
  end

  def not_found(conn, _opts \\ nil) do
    conn
    |> put_view(ErlangelistWeb.ErrorView)
    |> put_status(404)
    |> render("404.html")
  end
end
