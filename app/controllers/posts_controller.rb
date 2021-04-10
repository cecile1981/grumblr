class PostsController < ApplicationController
  before_action :set_post, only: %i[show edit update destroy]

  # GET /posts or /posts.json
  def index
    if current_user
      if !Post.where(only_followers: true)[0].nil? && !FollowerFollowed.where(follower_id: current_user.id)[0].nil?
# This one is a doosie.  It sorta starts in the middle and spirals out.  What we're trying to find here is all the public non-"Only Followers" posts as well as the posts that this user can see because they follow a user who has "Only Followers" posts.

# So first we find the FollowerFollowed models that have the current_user's id in the follower_id column.
# Then we pluck all the `followed_id`'s out, since those are the id's of the users this current_user is following.
# Then we find all the UserPost models that have those `followed_id`'s.
# Then we pluck all the `post_id`'s out of the UserPosts that we now have.  These are the ids of posts that the user the current_user follows has posted (what a sentence!)
# These ids are used to find Posts, but only posts with the matching id's that ALSO have `only_followers`set to true.
# Before ordering anything, we want to make sure that we still have all the public posts, so there's an `.or()` at the end getting all public ones.
# Lastly, we order them in descending order so the newest ones come up first.

        @posts = Post.where(id: UserPost.where(user_id: FollowerFollowed.where(follower_id: current_user.id).pluck(:followed_id)).pluck(:post_id), only_followers: true).or(Post.where(only_followers: false)).order(id: :desc)
      else
        @posts = Post.where(only_followers: false).order(id: :desc)
      end
    else
      @posts = Post.where(only_followers: false).order(id: :desc)
    end

  end

  # GET /posts/1 or /posts/1.json
  def show; end

  # GET /posts/new
  def new
    if current_user.nil?
      flash[:notice] = 'You need to be logged in to post.'
      redirect_to root_path
    else
      @post = Post.new
    end
  end

  # GET /posts/1/edit
  def edit; end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)
    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def post_params
    params.require(:post).permit(:content, :grass_tags, :only_followers)
  end
end
