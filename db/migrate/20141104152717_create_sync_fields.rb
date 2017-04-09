class CreateSyncFields < ActiveRecord::Migration
  def up
    create_table :sfsync_sync_fields do |t|
      t.string :sobject
      t.string :sf_field_name
      t.string :local_model
      t.string :local_field_name
      t.references :sync_query

      t.timestamps
    end
    add_index :sfsync_sync_fields, :sync_query_id
  end
  
  def down
    drop_table :sfsync_sync_fields
  end
end
