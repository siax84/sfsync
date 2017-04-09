module Sfsync
  class SobjectField < ActiveRecord::Base
    belongs_to :sobject
    self.inheritance_column = :_type_disabled
    #attr_accessible :auto_number, :byte_length, :calculated, :calculated_formula, :cascade_delete, :case_sensitive, :controller_name, :createable, :custom, :default_value, :default_value_formula, :defaulted_on_create, :dependent_picklist, :deprecated_and_hidden, :digits, :display_location_in_decimal, :external_id, :filterable, :groupable, :html_formatted, :id_lookup, :inline_help_text, :label, :length, :name, :name_field, :name_pointing, :nillable, :permissionable, :precision, :relationship_name, :relationship_order, :restricted_delete, :restricted_picklist, :scale, :soap_type, :sobject_name, :sortable, :type, :unique, :updateable, :write_requires_master_read
  end
end