class Sfsync::ApplicationController < ::ApplicationController

#http_basic_authenticate_with name: "sfsync", password: ""
# some special characters need escaping when called e.g. in a wget parameter

# before_action :authenticate_user!

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
        # Avoid problems with Integers and Floats    
        elsif (local_field.instance_of?(Integer) && remote_field.instance_of?(String)) || (local_field.instance_of?(Float) && remote_field.instance_of?(String))
          local_field = 0 if local_field.nil? # Prevent from failing when one field is nil
          remote_field = 0 if remote_field.nil?
            if local_field*1.0 != remote_field.to_i*1.0
              @diff = true
              @diff_fields << field.local_field_name
            end
        elsif (local_field.instance_of?(Integer) && remote_field.instance_of?(Float)) || (local_field.instance_of?(Float) && remote_field.instance_of?(Integer))
          local_field = 0 if local_field.nil? # Prevent from failing when one field is nil
          remote_field = 0 if remote_field.nil?
            if local_field*1.0 != remote_field*1.0
              @diff = true
              @diff_fields << field.local_field_name
            end                                                   
        elsif local_field.to_s != remote_sobject["#{field.sf_field_name}"].to_s
          unless ['updated_at', 'sf_updated_at', "latitude", "longitude"].include?(field.local_field_name) || 
            (remote_field.nil? && local_field == '') ||
            (remote_field == '' && local_field.nil? )
          @diff = true
          @diff_fields << field.local_field_name
          end           
        end   
      end
      print "#{local_object}, Fields: #{@diff_fields}\n" unless @diff_fields.empty?
      return @diff      
    end
  end   
end