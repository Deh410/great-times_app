class PlaysController < ApplicationController
  before_action :find_play, only: [:show, :edit, :update, :destroy]
  before_action :set_categories, only: [:update, :create]
  before_action :set_selection_collections, only: [:new,:create]
  before_action :authenticate_user!, only: [:new, :edit]
  # before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]
  after_action :attach_image, only: [:new, :edit, :create, :update]

  def index
    if params[:category].blank?
      @plays = Play.all.order("created_at DESC")
    else
      @category_id = Category.find_by(name: params[:category]).id
      @plays = Play.where(:category_id => @category_id).order("created_at DESC")
    end
  end

  def show
    if @play.reviews.blank?
      @average_review = 0
    else
      @average_review = @play.reviews.average(:rating).present? ? @play.reviews.average(:rating).round(2) : 0
    end
  end

  def new
    @play = current_user.plays.build
    @plays = Play.all
    @categories = Category.all
    @categories = Category.all.map{ |c| [c.name, c.id] }
  end

  def create
    @play = current_user.plays.build(play_params)
    @play.category_id = params[:category_id]
    # @play.age = params[:age]
    # @play.intruments_play = params[:intruments_play]
    # @play.instruments_own = params[:instruments_own]
    # @play.social = params[:social]
    # @play.setlist = params[:setlist]

    if @play.save
      redirect_to root_path
    else
      @play = Play.new
      render 'new'
    end
  end

  def edit
    @categories = Category.all.map{ |c| [c.name, c.id] }
  end

  def update 
    @play.category_id = params[:category_id]
    # @play.age = params[:age]
    # @play.intruments_play = params[:intruments_play]
    # @play.instruments_own = params[:instruments_own]
    # @play.social = params[:social]
    # @play.setlist = params[:setlist]

    if @play.update(play_params)
      redirect_to play_path(@play)
    else
      render 'edit'
    end
  end

  def destroy 
    @play.destroy
    redirect_to root_path
  end

  private

  def set_categories
    @categories = Category.all.map{ |c| [c.name, c.id]} 
  end

  def play_params
    params.require(:play).permit(:title, 
      :description, :director, :category_id, :image, :age, :intruments_play,
      :instruments_own, :social, :setlist)
  end

  def set_selection_collections
    @play = current_user.plays.build
  end

  def find_play
    @play = Play.find(params[:id])
  end

  def set_s3_direct_post
    s3 = Aws::S3::Resource.new
    s3_bucket = s3.bucket('stage-greattimes-app')
    @s3_direct_post = s3_bucket.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
  end

  def attach_image
    @play.image.attach(params[:image])
  end
end
