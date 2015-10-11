class RewardsController < ApplicationController
  resource_description do
    name 'Reviews'
    short 'Reviews'
    desc <<-EOS
      == Long description
        Store data for Mobile App Review Cues
      EOS

    api_base_url ""
    formats ['html', 'json']
  end

  def_param_group :rewards_data do
    param :rewards_enabled, :bool, :desc => "Rewards Enabled [Boolean]", :required => true
  end

  def_param_group :rewards_destroy_data do
    param :id, :number, :desc => "Id of Reward Record to Delete [Number]", :required => true
  end

  acts_as_token_authentication_handler_for User

  before_action :authenticate_user!
  before_action :set_reward, only: [:show, :edit, :update, :destroy]

  after_action :verify_authorized

  respond_to :html, :json

  api! "Show Rewards Record"
  def index
    authorize :reminder, :index?
    @user = User.find_by_id(params[:user_id])

    if @user == nil
      @reward = Reward.where(user_id: current_user.id)
    elsif @user != nil
      @reward = Reward.where(user_id: @user.id)
    end

    respond_to do |format|
      format.html
      format.json { render :json => @reward, status: 200 }
    end
  end

  def show
    authorize :reminder, :show?
    
    respond_to do |format|
      format.html
      format.json { render :json => @reward, status: 200 }
    end
  end

  def new
    authorize :reminder, :new?
    @reward = Reward.new
    
    respond_to do |format|
      format.html
      format.json { render :json => @reward, status: 200 }
    end
  end

  api! "Edit Reward Record"
  def edit
    authorize :reminder, :edit?

    respond_to do |format|
      format.html
      format.json { render :json => @reward, status: 200 }
    end
  end

  api! "Create Reward Record"
  param_group :rewards_data
  def create
    authorize :reminder, :create?
    @reward = Reward.new(reward_params)
    @reward.save
    
    respond_to do |format|
      format.html
      format.json { render :json => @reward, status: 200 }
    end
  end

  api! "Update Reward Record"
  param_group :rewards_data
  def update
    authorize :reminder, :update?
    @reward.update(reward_params)
    
    respond_to do |format|
      format.html
      format.json { render :json => @reward, status: 200 }
    end
  end

  api! "Delete Reward Record"
  param_group :rewards_destroy_data
  def destroy
    authorize :reminder, :destroy?
    @reward.destroy
    
    respond_to do |format|
      format.html
      format.json  { head :no_content }
    end
  end

  private
    def set_reward
      @reward = Reward.find(params[:id])
    end

    def reward_params
      params.fetch(:reward, {}).permit(:user_id, :rewards_enabled)
    end
end
