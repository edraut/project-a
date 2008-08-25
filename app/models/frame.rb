class Frame < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  has_many :positions, :dependent => :destroy
  has_many :white_positions, :class_name => 'Position', :conditions => 'player_id = #{self.game.white_player.id}'
  has_many :black_positions, :class_name => 'Position', :conditions => 'player_id = #{self.game.black_player.id}'
  
  def next_player
    player.opponent
  end
  
  def ko?(x,y)
    if game.penultimate_frame
      if game.penultimate_frame.positions.captured.length == 1 and game.penultimate_frame.positions.captured.first.has_coordinates(x,y)
        self.errors.add_to_base 'That position is in Ko, you must wait a turn before moving there.'
        return true
      else
        return false
      end
    else
      return false
    end
  end
  
  def inspect_position(x,y)
    if x >= game.size or x < 0 or y >= game.size or y < 0
      return false
    else
      position_at_coordinates(x,y).player_id
    end
  end

  def will_capture?(x,y)
    captured_group = []
    for position_array in [[x+1,y],[x-1,y],[x,y+1],[x,y-1]]
      liberty_args = []
      liberty_args.push *position_array
      liberty_args.push game.next_player
debugger
      count, connected_group = liberty_count(*liberty_args)
      if inspect_position(*position_array) == game.next_player.id
        connected_group.push position_array
      end
      if count == 1
        captured_group.push *connected_group
      end
    end
    if captured_group.length > 0
      return captured_group
    else
      return false
    end
  end
  
  def capture(x,y)
    position_at_coordinates(x,y).update_attributes(:player_id => nil,:captured => true)
  end
  
  def suicide?(x,y)
    count, connected_group = liberty_count(x,y,game.current_player)
    if count < 1
      self.errors.add_to_base 'Moving there would be suicide. Choose another position.'
      return true
    end
    return false
  end
  
  def check_status(x,y)
    result = MOVE_ALLOWED
    case inspect_position(x,y)
    when nil
      if ko?(x,y)
        result = CANT_MOVE
      elsif capture_positions = will_capture?(x,y)
        capture_positions.each do |capture_position|
          capture(*capture_position)
        end
        result = MOVE_ALLOWED
      elsif suicide?(x,y)
        result = CANT_MOVE
      end
    when game.black_player.id,game.white_player.id
      self.errors.add_to_base 'That position is already taken'
      result = CANT_MOVE
    when false
      result = CANT_MOVE
    end
    return result
  end

  def liberty_count(x,y,this_player,already_counted = [])
    already_counted << [x,y]
    count = 0
    connected_group = []
    [[x+1,y],[x-1,y],[x,y+1],[x,y-1]].each do |position_array|
      unless already_counted.include?(position_array)
        case inspect_position(*position_array)
        when nil
          count += 1
        when this_player.id
          connected_group.push [position_array[0],position_array[1]]
          this_count, new_connected_group = liberty_count(*((position_array << this_player) << already_counted))
          count += this_count
          connected_group.push *new_connected_group
        end
        already_counted << position_array
      end
    end
    return count, connected_group
  end

  def set_position(x,y,state)
    if game.allowed_states.include?(state)
      if game.size > x and game.size > y
        position_at_coordinates(x,y).update_attributes(:player_id => state)
      else
        self.errors.add_to_base 'That Position is not on the board.'
      end
    else
      self.errors.add_to_base 'Not a valid player'
    end
  end
  
  def played_position
    positions.played.first
  end
      
  def position_at_coordinates(x,y)
    positions.at_coordinates([x,y]).first
  end

  def deep_clone
    new_frame = Frame.create(:game_id => game_id, :player_id => player.opponent.id)
    position_attrs = []
    positions.each do |position|
      puts position.attributes.inspect
      new_position_attrs =  position.attributes.dup.merge(:frame_id => new_frame.id, :played => false, :captured => :false)
      position_attrs << new_position_attrs
    end
    Position.transaction do
      Position.create(position_attrs)
    end
    new_frame.reload
    return new_frame
  end
  
  def blank_fill
    position_attrs = []
    game.size.times do |x|
      game.size.times do |y|
        if game.handicap_positions.include? [x,y]
          position_attrs << {:x => x, :y => y, :frame_id => id, :player_id => game.black_player.id, :played => false}
        else
          position_attrs << {:x => x, :y => y, :frame_id => id, :played => false}
        end
      end
    end
    Position.transaction do
      Position.create(position_attrs)
    end
  end
  
end
