class GamesController < ApplicationController
  before_filter :set_render
  before_filter :login_required
  before_filter :get_game, :except => [:index, :new, :create]
  before_filter :get_user

  def index
    @games = @user.games
    if @games.length > 0
      render :action => 'index'
    else
      @game = Game.new
      render :action => 'new'
    end
  end
  
  def show
    if params[:polling_for_turn]
      if @game.next_player == @game.this_player(@user.id)
        render :text => "{ played : { col: #{@game.latest_frame.played_position.x}, row: #{@game.latest_frame.played_position.y} }, captured : [ #{@game.latest_frame.positions.captured.collect{|c| '{col: ' + c.x.to_s + ', row: ' + c.y.to_s + '}'}.join(', ')}]}", :status => 200
      else
        render :nothing => true, :status => 503
      end
    else
      render :nothing => true
    end
  end
  
  def new
    @game = Game.new
    render @render_key => 'new'
  end
  
  def create
    @game = Game.create(params[:game])
    this_player_class_name = params[:this_player_class]
    this_player_association = this_player_class_name.underscore
    this_player = this_player_class_name.constantize.create(:user_id => session[:user_id])
    @game.send((this_player_association + '=').to_sym, this_player)
    case this_player_class_name
    when 'BlackPlayer'
      opponent_class_name = 'WhitePlayer'
    when 'WhitePlayer'
      opponent_class_name = 'BlackPlayer'
    end
    opponent_association = opponent_class_name.underscore
    opponent = opponent_class_name.constantize.create(params[:opponent])
    @game.send((opponent_association + '=').to_sym, opponent)
    @first_frame = Frame.new(:player_id => (@game.handicap > 0) ? @game.black_player.id : @game.white_player.id)
    @game.frames << @first_frame
    @first_frame.blank_fill
    if @game.save
      render @render_key => 'edit'
    else
      render @render_key => 'new'
    end
  end

  def edit
    render @render_key => 'edit'
  end
  
  def update
    @this_player = @game.players.with_user_id(session[:user_id]).first
    @game.move(params[:col].to_i, params[:row].to_i, @this_player)
    respond_to do |format|
      format.html do
        if @game.errors.empty?
          if @game.latest_frame.positions.captured.length > 0
            render :text => "[#{@game.latest_frame.positions.captured.collect{|p| '{col:' + p.x.to_s + ', row:' + p.y.to_s + '}'}.join(', ')}]", :status => 200
          else
            render :text => "[{col: -1, row: -1}]", :status => 200
          end
        else
          render :text => @game.errors.full_messages.join(' * '), :status => 403
        end
      end
    end
  end
  
  protected
  
  def get_game
    @game = Game.find(params[:id])
  end

  def get_user
    @user = User.find(session[:user_id])
  end
  
  def set_render
    
    if params[:partial]
      @render_key = :partial
    else
      @render_key = :action
    end
  end
  
end