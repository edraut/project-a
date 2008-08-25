class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.integer :size, :default => 19
      t.integer :handicap, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end
