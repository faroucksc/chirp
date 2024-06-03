defmodule ChirpWeb.PostLive.PostComponent do
  use ChirpWeb, :live_component
  alias Chirp.Timeline

  def update(assigns, socket) do
    {:ok, assign(socket, :posts, assigns.posts)}
  end

  def render(assigns) do
    ~H"""
    <div id="posts" phx-update="prepend">
      <%= for {_id, post} <- @posts do %>
        <div id={"post-#{post.id}"} phx-click={JS.navigate(~p"/posts/#{post}")} class="post-body">
          <div class="username"><%= post.username %></div>
          <div class="post-content"><%= post.body %></div>
          <div class="post-stats">
          </div>
          <div class="actions">
            <button class="edit-action">
              <.link patch={~p"/posts/#{post}/edit"}><i class="fas fa-edit"></i></.link>
            </button>
            <button class="delete-action">
              <.link phx-click={JS.push("delete", value: %{id: post.id}) |> hide("#post-#{post.id}")} data-confirm="Are you sure?">
                <i class="fas fa-trash"></i>
              </.link>
            </button>
            <button class="like-action" phx-click="like" phx-value-post_id={post.id} >
              <i class="fas fa-heart"></i>
              <%= post.likes_count %>
            </button>
            <button class="repost-action" phx-click="repost" phx-value-id={post.id} phx-target={@myself}>
              <i class="fas fa-retweet"></i><%= post.reposts_count %>
            </button>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  # def handle_event("like", %{"post_id" => post_id}, socket) do
  #   post = Chirp.Timeline.get_post!(post_id)
  #   Chirp.Timeline.like_post(post_id)
  #   {:noreply, socket}
  # end

  def handle_event("repost", %{"id" => post_id}, socket) do
    post = Timeline.get_post!(post_id)
    Chirp.Timeline.repost_post(post_id)
    {:noreply, socket}
  end
end
