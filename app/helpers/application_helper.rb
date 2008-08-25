# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def get_cell_image(game,row,col)
    if Game::DOTTED_POSITIONS[game.size].include? [row,col]
  		position_class = 'board-cell-dot'
  	elsif row == 0
  		if col == 0
  			position_class = 'board-cell-top-left'
			elsif col == game.size - 1
			  position_class = 'board-cell-top-right'
		  else
		    position_class = 'board-cell-top'
		  end
    elsif row == game.size - 1
      if col == 0
        position_class = 'board-cell-bottom-left'
      elsif col == game.size - 1
        position_class = 'board-cell-bottom-right'
		  else
		    position_class = 'board-cell-bottom'
      end
    elsif col == 0
      position_class = 'board-cell-left'
    elsif col == game.size - 1
      position_class = 'board-cell-right'
  	else
      position_class = 'board-cell-middle' 
  	end
    return position_class
	end
end
