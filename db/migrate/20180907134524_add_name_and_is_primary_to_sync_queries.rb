class AddNameAndIsPrimaryToSyncQueries < ActiveRecord::Migration
  def change
    add_column :sfsync_sync_queries, :name, :string
    add_column :sfsync_sync_queries, :is_primary, :boolean, :default => false
  end
end
