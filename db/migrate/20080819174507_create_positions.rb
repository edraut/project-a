class CreatePositions < ActiveRecord::Migration
  def self.up
    create_table :positions do |t|
      t.references :frame
      t.integer :x
      t.integer :y
      t.references :player
      t.boolean :captured
      t.boolean :played

      t.timestamps
    end
  end

  def self.down
    drop_table :positions
  end
end
