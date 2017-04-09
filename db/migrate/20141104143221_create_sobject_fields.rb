class CreateSobjectFields < ActiveRecord::Migration
  def change
    create_table :sfsync_sobject_fields do |t|
      t.references :sobject
      t.string :sobject_name
      t.boolean :auto_number
      t.integer :byte_length
      t.boolean :calculated
      t.text :calculated_formula
      t.boolean :cascade_delete
      t.boolean :case_sensitive
      t.string :controller_name
      t.boolean :createable
      t.boolean :custom
      t.string :default_value
      t.string :default_value_formula
      t.boolean :defaulted_on_create
      t.boolean :dependent_picklist
      t.boolean :deprecated_and_hidden
      t.integer :digits
      t.boolean :display_location_in_decimal
      t.boolean :external_id
      t.boolean :filterable
      t.boolean :groupable
      t.boolean :html_formatted
      t.boolean :id_lookup
      t.text :inline_help_text
      t.string :label
      t.integer :length
      t.string :name
      t.boolean :name_field
      t.boolean :name_pointing
      t.boolean :nillable
      t.boolean :permissionable
      t.integer :precision
      #t.text :reference_to
      t.string :relationship_name
      t.string :relationship_order
      t.boolean :restricted_delete
      t.boolean :restricted_picklist
      t.integer :scale
      t.string :soap_type
      t.boolean :sortable
      t.string :type
      t.boolean :unique
      t.boolean :updateable
      t.boolean :write_requires_master_read

      t.timestamps
    end
    add_index :sfsync_sobject_fields, :sobject_id
  end
end
