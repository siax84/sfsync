class Sfsync::ApplicationController < ::ApplicationController

before_filter :authenticate_user!

  def different? local_object, remote_sobject, sync_fields
      if local_object && remote_sobject
        @diff = false
        @diff_fields = Array.new
        sync_fields.each do |field|
          local_field = local_object["#{field.local_field_name}"]
          remote_field = remote_sobject["#{field.sf_field_name}"]
          if local_field.instance_of? Date    
              if local_field.strftime("%F") != remote_field
                @diff = true
                @diff_fields << field.local_field_name
              end                        
          elsif local_field != remote_sobject["#{field.sf_field_name}"]
            unless ['updated_at', 'sf_updated_at', "latitude", "longitude"].include?(field.local_field_name) || 
              (remote_field.nil? && local_field == '') ||
              (remote_field == '' && local_field.nil? )
            @diff = true
            @diff_fields << field.local_field_name
            end           
          end   
        end  
      end         
      print "Fields: #{@diff_fields}\n"
      return @diff
    end   
end