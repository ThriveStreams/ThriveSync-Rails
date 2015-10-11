class MessagesController < ApplicationController
  resource_description do
    name 'T-Max Cards'
    short 'T-Max Cards'
    desc <<-EOS
      == Long description
        Send Cards between Supporters and their Thrivers
      EOS

    api_base_url ""
    formats ['html', 'json']
  end

  def_param_group :messages_data do
    param :user_id, :number, :desc => "Id of Recipient of T-Max Card [Number]", :required => true
    param :body, :undef, :desc => "Message [String]", :required => true
    param :subject, :undef, :desc => "Category [String]", :required => true
  end

  acts_as_token_authentication_handler_for User

  before_action :authenticate_user!
  before_action :set_thriver, only: [:new, :create]

  after_action :verify_authorized

  respond_to :html, :json

  def new
    authorize :message, :new?
  	c = PreDefinedCard.all
  	random_ids = c.ids.sort_by { rand }.slice(0, 3)
  	@random_cards = PreDefinedCard.where(:id => random_ids)
  end

  api! "Send T-Max Card"
  param_group :messages_data
  def create
    # Limit Sending Messages between Supporters and their Thrivers
    if (current_user.is? :supporter) && (@thriver.supporters.include? current_user.id)
      skip_authorization
    else
      authorize :message, :create?
    end

    recipients = User.where(id: @thriver.id)
    conversation = current_user.send_message(recipients, params[:message][:body], params[:message][:subject]).conversation
    flash[:success] = "Message has been sent!"

    respond_to do |format|
      format.html { redirect_to supporters_path }
      format.json { head :ok }
    end 
  end

  api! "Draw Random T-Max Cards"
  def random_draw
    authorize :message, :random_draw?
    c = PreDefinedCard.all
    random_ids = c.ids.sort_by { rand }.slice(0, 3)
    @random_cards = PreDefinedCard.where(:id => random_ids)

    respond_to do |format|
      format.json { render :json => { :cards => @random_cards }, status: 200}
    end 
  end

  private

  def set_thriver
    @thriver = User.find(params[:thriver_id])
  end
end