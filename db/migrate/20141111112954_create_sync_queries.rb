class CreateSyncQueries < ActiveRecord::Migration
  def change
    create_table :sfsync_sync_queries do |t|
      t.string :local_model
      t.string :sobject
      t.text :where_conditions
      t.datetime :created_filter
      t.string :created_operator
      t.datetime :last_modified_filter
      t.string :last_modified_operator

      t.timestamps
    end
  end
end
