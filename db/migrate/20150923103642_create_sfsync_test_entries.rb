class CreateSfsyncTestEntries < ActiveRecord::Migration
  def change
    create_table :sfsync_test_entries do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
