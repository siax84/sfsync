module Sfsync
  class SyncQuery < ActiveRecord::Base
    has_many :sync_fields
    
    def current_sync_fields
        #make sure to sync only fields that belong to the right objects
        sync_fields = self.sync_fields
          .where(:local_model => self.local_model)
          .where(:sobject => self.sobject)
          .order(:sf_field_name) 
    end
    
    def to_s
      "#{self.sobject} (#{self.where_conditions}) --> #{self.local_model}"
    end
  end
end