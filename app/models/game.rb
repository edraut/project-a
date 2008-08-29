class Game < ActiveRecord::Base
  has_many :players
  has_one :black_player, :dependent => :destroy
  has_one :white_player, :dependent => :destroy
  has_many :frames, :dependent => :destroy
  has_many :users, :through => :players

  DOTTED_POSITIONS = {
    19 => [[3,3],[9,3],[15,3],[3,9],[9,9],[15,9],[3,15],[9,15],[15,15]],
    17 => [[3,3],[8,3],[13,3],[3,8],[9,9],[13,8],[3,13],[8,13],[13,13]],
    15 => [[3,3],[7,3],[11,3],[3,7],[7,7],[11,7],[3,11],[7,11],[11,11]], 
    13 => [[3,3],[9,3],[6,6],[3,9],[9,9]],
    11 => [[2,2],[8,2],[5,5],[2,8],[8,8]],
    9 => [[2,2],[6,2],[4,4],[2,6],[6,6]],
    7 => [[2,2],[4,2],[2,4],[4,4]]
  }

  HANDICAP_POSITIONS = [[:e,:b],[:b,:e],[:b,:b],[:e,:e],[:b,:m],[:e,:m],[:m,:b],[:m,:e],nil]
  
  def handicap_positions
    if @handicap_positions
      return @handicap_positions
    elsif self.handicap < 1
      @handicap_positions = []
      return @handicap_positions
    end
    positions = HANDICAP_POSITIONS[0..(self.handicap - 1)].dup
    case size
    when 13,15,17,19
      end_offset = -4
      beginning_offset = 3
    when 9,11
      end_offset = -3
      beginning_offset = 2
    when 7
      if self.handicap > 4
        @self.errors.add_to_base 'The maximum handicap for a 7x7 board is 4 stones.'
        self.handicap = 4
      end
      end_offset = -3
      beginning_offset = 2
    end
    case self.handicap
    when 5,7,9
      positions.pop
      positions.push [:m,:m]
    end
    @handicap_positions = positions.collect do |p|
      p.collect do |amount|
        case amount
        when :m 
          amount = (size - 1) / 2
        when :e
          amount = size + end_offset
        when :b
          amount = beginning_offset
        end
        amount
      end
    end
    return @handicap_positions
  end
  
  def this_player(user_id)
    players.select{|player| player.user_id == user_id}.first
  end
  
  def current_player
    latest_frame.player
  end

  def next_player
    current_player.opponent
  end
  
  def opponent(user_id)
    players.select{|player| player.user_id != user_id}.first
  end
    
  def latest_frame
    frames.sort{|a,b| a.id <=> b.id}.last
  end
  
  def latest_played_position
    latest_frame.played_position
  end
  
  def penultimate_frame
    frames.sort{|a,b| a.id <=> b.id}[-2]
  end
  
  def allowed_states
    [white_player.id,black_player.id,nil]
  end
  
  def move( x, y, player )
    if player == next_player
      if size > x and size > y
        self.frames << latest_frame.deep_clone
        if latest_frame.check_status( x, y ) == MOVE_ALLOWED
          latest_frame.set_position( x, y, player.id )
          if latest_frame.errors.empty? 
            latest_frame.position_at_coordinates(x,y).update_attributes(:played => true)
            return true
          else
            return false
          end
        else
          latest_frame.errors.each do | attr, error |
            self.errors.add_to_base error
          end
          latest_frame.destroy
          reload
        end
      else
        self.errors.add_to_base 'That move would be outside the bounds.'
      end
    else
      self.errors.add_to_base "It's not your turn."
    end      
    return false
  end
  
  def pass(player)
    if verify_player(player)
      next_board
    end
  end
  
end
