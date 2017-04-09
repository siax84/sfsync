class CreateSobjects < ActiveRecord::Migration
  def change
    create_table :sfsync_sobjects do |t|
      t.boolean :activateable
      t.boolean :createable
      t.boolean :custom
      t.boolean :custom_setting
      t.boolean :deletable
      t.boolean :deprecated_and_hidden
      t.boolean :feed_enabled
      t.string :key_prefix
      t.string :label
      t.string :label_plural
      t.boolean :layoutable
      t.boolean :listviewable
      t.boolean :lookup_layoutable
      t.boolean :mergeable
      t.string :name
      t.boolean :queryable
      t.boolean :replicateable
      t.boolean :retrieveable
      t.boolean :search_layoutable
      t.boolean :searchable
      t.boolean :triggerable
      t.boolean :undeletable
      t.boolean :updateable

      t.timestamps
    end
  end
end
