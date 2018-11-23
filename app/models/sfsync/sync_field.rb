module Sfsync
  class SyncField < ActiveRecord::Base
    belongs_to :sync_query
    #attr_accessible :local_field_name, :local_model, :sf_field_name, :sobject
    
    def local_name
      local_field_name
    end
    
    def remote_name
      sf_field_name
    end
  end
end
