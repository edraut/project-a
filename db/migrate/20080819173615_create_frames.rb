class CreateFrames < ActiveRecord::Migration
  def self.up
    create_table :frames do |t|
      t.references :game
      t.references :player

      t.timestamps
    end
  end

  def self.down
    drop_table :frames
  end
end
