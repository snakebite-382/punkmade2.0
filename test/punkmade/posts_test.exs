defmodule Punkmade.PostsTest do
  use Punkmade.DataCase

  alias Punkmade.Posts

  describe "posts" do
    alias Punkmade.Posts.Post

    import Punkmade.PostsFixtures

    @invalid_attrs %{body: nil, private: nil, scene_id: nil, title: nil, user_id: nil}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Posts.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Posts.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{body: "some body", private: true, scene_id: 42, title: "some title", user_id: 42}

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)
      assert post.body == "some body"
      assert post.private == true
      assert post.scene_id == 42
      assert post.title == "some title"
      assert post.user_id == 42
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{body: "some updated body", private: false, scene_id: 43, title: "some updated title", user_id: 43}

      assert {:ok, %Post{} = post} = Posts.update_post(post, update_attrs)
      assert post.body == "some updated body"
      assert post.private == false
      assert post.scene_id == 43
      assert post.title == "some updated title"
      assert post.user_id == 43
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end
  end

  describe "comments" do
    alias Punkmade.Posts.Comment

    import Punkmade.PostsFixtures

    @invalid_attrs %{content: nil}

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      assert Posts.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert Posts.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      valid_attrs = %{content: "some content"}

      assert {:ok, %Comment{} = comment} = Posts.create_comment(valid_attrs)
      assert comment.content == "some content"
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_comment(@invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()
      update_attrs = %{content: "some updated content"}

      assert {:ok, %Comment{} = comment} = Posts.update_comment(comment, update_attrs)
      assert comment.content == "some updated content"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = comment_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_comment(comment, @invalid_attrs)
      assert comment == Posts.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = Posts.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = Posts.change_comment(comment)
    end
  end

  describe "likes" do
    alias Punkmade.Posts.Like

    import Punkmade.PostsFixtures

    @invalid_attrs %{post_id: nil, user_id: nil}

    test "list_likes/0 returns all likes" do
      like = like_fixture()
      assert Posts.list_likes() == [like]
    end

    test "get_like!/1 returns the like with given id" do
      like = like_fixture()
      assert Posts.get_like!(like.id) == like
    end

    test "create_like/1 with valid data creates a like" do
      valid_attrs = %{post_id: 42, user_id: 42}

      assert {:ok, %Like{} = like} = Posts.create_like(valid_attrs)
      assert like.post_id == 42
      assert like.user_id == 42
    end

    test "create_like/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_like(@invalid_attrs)
    end

    test "update_like/2 with valid data updates the like" do
      like = like_fixture()
      update_attrs = %{post_id: 43, user_id: 43}

      assert {:ok, %Like{} = like} = Posts.update_like(like, update_attrs)
      assert like.post_id == 43
      assert like.user_id == 43
    end

    test "update_like/2 with invalid data returns error changeset" do
      like = like_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_like(like, @invalid_attrs)
      assert like == Posts.get_like!(like.id)
    end

    test "delete_like/1 deletes the like" do
      like = like_fixture()
      assert {:ok, %Like{}} = Posts.delete_like(like)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_like!(like.id) end
    end

    test "change_like/1 returns a like changeset" do
      like = like_fixture()
      assert %Ecto.Changeset{} = Posts.change_like(like)
    end
  end

  describe "comment_likes" do
    alias Punkmade.Posts.CommentLike

    import Punkmade.PostsFixtures

    @invalid_attrs %{comment_id: nil, user_id: nil}

    test "list_comment_likes/0 returns all comment_likes" do
      comment_like = comment_like_fixture()
      assert Posts.list_comment_likes() == [comment_like]
    end

    test "get_comment_like!/1 returns the comment_like with given id" do
      comment_like = comment_like_fixture()
      assert Posts.get_comment_like!(comment_like.id) == comment_like
    end

    test "create_comment_like/1 with valid data creates a comment_like" do
      valid_attrs = %{comment_id: 42, user_id: 42}

      assert {:ok, %CommentLike{} = comment_like} = Posts.create_comment_like(valid_attrs)
      assert comment_like.comment_id == 42
      assert comment_like.user_id == 42
    end

    test "create_comment_like/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_comment_like(@invalid_attrs)
    end

    test "update_comment_like/2 with valid data updates the comment_like" do
      comment_like = comment_like_fixture()
      update_attrs = %{comment_id: 43, user_id: 43}

      assert {:ok, %CommentLike{} = comment_like} = Posts.update_comment_like(comment_like, update_attrs)
      assert comment_like.comment_id == 43
      assert comment_like.user_id == 43
    end

    test "update_comment_like/2 with invalid data returns error changeset" do
      comment_like = comment_like_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_comment_like(comment_like, @invalid_attrs)
      assert comment_like == Posts.get_comment_like!(comment_like.id)
    end

    test "delete_comment_like/1 deletes the comment_like" do
      comment_like = comment_like_fixture()
      assert {:ok, %CommentLike{}} = Posts.delete_comment_like(comment_like)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_comment_like!(comment_like.id) end
    end

    test "change_comment_like/1 returns a comment_like changeset" do
      comment_like = comment_like_fixture()
      assert %Ecto.Changeset{} = Posts.change_comment_like(comment_like)
    end
  end
end
