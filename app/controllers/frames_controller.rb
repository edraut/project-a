class FramesController < ApplicationController
  before_filter :login_required
  before_filter :get_frame, :except => [:index, :new, :create]
  before_filter :get_game, :only => [:index, :new, :create]
  def index
    @frames = @game.frames
  end
  
  def new
    @frame = Frame.new
    render :partial => 'error', :object => @frame, :status => 403
  end
  
  def create
    @frame = Frame.new
    @game.frames << @frame
    render :text => 'hoooohah', :object => @frame, :status => 409
    if @frame.save
    else
    end
  end
  
  def edit
    render @render_key => 'edit'
  end
  
  def update
    @frame.errors.add_to_base('nope.')
    respond_to do |format|
      format.html do
        render :partial => 'frame_error', :object => @frame, :status => 403
      end
    end
  end
  
  protected
  
  def get_frame
    @frame = Frame.find(params[:id])
  end

  def get_game
    @game = Game.find(params[:game_id])
  end
end