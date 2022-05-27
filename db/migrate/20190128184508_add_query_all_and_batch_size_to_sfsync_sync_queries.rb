class AddQueryAllAndBatchSizeToSfsyncSyncQueries < ActiveRecord::Migration
  def change
    add_column :sfsync_sync_queries, :query_all, :boolean, :default => false
    add_column :sfsync_sync_queries, :batch_size, :integer, :default => 1000
  end
end
