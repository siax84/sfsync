class CreateSyncModels < ActiveRecord::Migration
  def change
    create_table :sfsync_sync_models do |t|
      t.string :local_name

      t.timestamps
    end
  end
end
