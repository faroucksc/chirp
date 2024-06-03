defmodule ChirpWeb.PostLive.Index do
  use ChirpWeb, :live_view
  alias Chirp.Timeline
  alias Chirp.Timeline.Post

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    posts = Timeline.list_posts()
    # {:ok, stream(socket, :posts, posts, temporary_assigns: [posts: []])}
    {:ok, stream(socket, :posts, posts)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, Timeline.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Post Timeline")
    |> assign(:post, nil)
  end

  @impl true
  def handle_info({ChirpWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    # {:noreply, stream_insert(socket, :posts, post, at: 0)}
    IO.puts(
      "######################################## handle_info chirpweb saved  ##########################################"
    )

    {:noreply, stream_insert(socket, :posts, post, at: 0)}
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    IO.puts(
      "######################################## handle_info Generic created  ##########################################"
    )

    # {:noreply, stream_insert(socket, :posts, post, at: 0)}
    {:noreply, stream_insert(socket, :posts, post, at: 0)}
  end

  def handle_info({:post_updated, post}, socket) do
    IO.puts(
      "######################################## handle_info Generic updated  ##########################################"
    )

    # {:noreply, stream_insert(socket, :posts, post, at: 0)}
    {:noreply, stream_insert(socket, :posts, post)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Timeline.get_post!(id)
    {:ok, _} = Timeline.delete_post(post)
    {:noreply, stream_delete(socket, :posts, post)}
  end

  def handle_event("like", %{"post_id" => post_id}, socket) do
    post = Timeline.get_post!(post_id)
    Chirp.Timeline.like_post(post_id)
    {:noreply, socket}
  end

  def handle_event("repost", %{"post_id" => post_id}, socket) do
    post = Timeline.get_post!(post_id)
    Chirp.Timeline.repost_post(post_id)
    {:noreply, socket}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    case Chirp.Timeline.create_post(post_params) do
      {:ok, post} ->
        Phoenix.PubSub.broadcast(Chirp.PubSub, "posts", {:post_created, post})
        # {:noreply, stream_insert(socket, :posts, post, at: 0)}
        IO.puts(
          "######################################## handle_info Generic save end  ##########################################"
        )

        {:noreply, stream_insert(socket, :posts, post, at: 0)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end
end
