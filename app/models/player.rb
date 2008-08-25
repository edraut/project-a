class Player < ActiveRecord::Base
  belongs_to :game
  belongs_to :user
  has_many :frames
  has_many :positions
  named_scope :with_user_id, lambda { |user_id| {:conditions => {:user_id => user_id}}}
  
  def opponent
    game.players.detect{|player| player.id != self.id}
  end
end
