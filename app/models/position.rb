class Position < ActiveRecord::Base
  belongs_to :frame
  belongs_to :player
  named_scope :captured, :conditions => {:captured => true}
  named_scope :empty, :conditions => {:player_id => nil}
  named_scope :at_coordinates, lambda { |coordinates| {:conditions => {:x => coordinates[0],:y => coordinates[1]}}}
  named_scope :played, :conditions => {:played => true}
  
  def has_coordinates(this_x,this_y)
    x == this_x and y == this_y
  end

end
