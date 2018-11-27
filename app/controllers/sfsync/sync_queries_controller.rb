require_dependency "sfsync/application_controller"
module Sfsync
  class SyncQueriesController < ApplicationController
    respond_to :html
    before_action :set_sync_query, only: [:show, :edit, :update, :destroy]
    def sync_down
      @sync_query = SyncQuery.find(params[:id])
      if @sync_query.sobject && @sync_query.local_model   
        client = Restforce.new
        
        #make sure to sync only fields that belong to the right objects
        sync_fields = @sync_query.current_sync_fields
                  
        query_string = "SELECT Id, #{sync_fields.pluck(:sf_field_name).join(',')} FROM #{@sync_query.sobject} WHERE #{@sync_query.where_conditions}"        
        print "SOQL Query: " + query_string
        
        @remote_sobjects = client.query(query_string)
        @remote_sobjects.each do |remote_sobject|
          sync_sf_to_local(@sync_query, sync_fields, remote_sobject)
        end 
      end
      respond_to do |format|
        format.html { redirect_to sync_queries_url, :notice => 'Synchronized successfully' }
        format.json { head :no_content }
      end
    end
    
    def compare
      @title = 'Compare local vs. Salesforce'      
      local_object_id = params[:local_object_id]
      next_id = params[:next_id]
      previous_id = params[:previous_id]
      @sync_query = SyncQuery.find(params[:id])      
      
      if @sync_query.sobject && @sync_query.local_model        
        @local_object = @sync_query.local_model.constantize.find_by_id(local_object_id)
        client = Restforce.new
        
        @sync_fields = @sync_query.current_sync_fields    
        
        # we need to make sure that we have lastModiefiedDate for comparison of the objects, but if it was already mapped to a field it would occur twice in the SOQL query
        if @sync_fields.pluck(:sf_field_name).include? 'LastModifiedDate'          
          query_string = "SELECT Id, #{@sync_fields.pluck(:sf_field_name).join(',')} FROM #{@sync_query.sobject} WHERE Id = '#{@local_object.sf_id}'"
        else
          query_string = "SELECT Id, LastModifiedDate, #{@sync_fields.pluck(:sf_field_name).join(',')} FROM #{@sync_query.sobject} WHERE Id = '#{@local_object.sf_id}'"
        end        
        
        print "SOQL Query: " + query_string
        @remote_object = client.query(query_string).first

        @diff = different? @local_object, @remote_object, @sync_fields
        render :layout => false
      end
      
    end
    
    def merge      
      local_object_id = params[:local_object_id]
      @sync_query = SyncQuery.find(params[:id])      
      
      if @sync_query.sobject && @sync_query.local_model        
        @local_object = @sync_query.local_model.constantize.find_by_id(local_object_id)
        client = Restforce.new
        
        @sync_fields = @sync_query.current_sync_fields    
        
        # we need to make sure that we have lastModiefiedDate for comparison of the objects, but if it was already mapped to a field it would occur twice in the SOQL query
        if @sync_fields.pluck(:sf_field_name).include? 'LastModifiedDate'          
          query_string = "SELECT Id, #{@sync_fields.pluck(:sf_field_name).join(',')} FROM #{@sync_query.sobject} WHERE Id = '#{@local_object.sf_id}'"
        else
          query_string = "SELECT Id, LastModifiedDate, #{@sync_fields.pluck(:sf_field_name).join(',')} FROM #{@sync_query.sobject} WHERE Id = '#{@local_object.sf_id}'"
        end        
        
        print "SOQL Query: " + query_string
        @remote_object = client.query(query_string).first
      end
      
      if params[:merge] == 'true'
        flash[:notice] = merge_values @sync_query, @remote_object, params        
      end
      
      respond_with @sync_query do |format|
        format.js { render :layout => false }
      end         
    end
    
    def resolve
      @sync_query = Sfsync::SyncQuery.find(params[:id])
      if @sync_query.sobject && @sync_query.local_model   
            client = Restforce.new
            sync_fields = Sfsync::SyncField.where(:local_model => @sync_query.local_model)
              .where(:sobject => @sync_query.sobject)
              .where(:sync_query_id => @sync_query.id)          
            query_string = "SELECT Id, #{sync_fields.pluck(:sf_field_name).join(',')} FROM #{@sync_query.sobject} WHERE #{@sync_query.where_conditions}"
            print "SOQL Query: " + query_string
            @remote_sobjects = client.query(query_string)
      end
      @list = Array.new
      @remote_sobjects.each do |remote_sobject|
        local_object = @sync_query.local_model.constantize.find_by(:sf_id => remote_sobject.Id)
        if local_object
          diff = different?(local_object, remote_sobject, sync_fields)
        end
        if diff == true
          @list << [local_object, @diff_fields]        
        end
        
      end      
    end   
    
    # GET /sf/sync_queries
    # GET /sf/sync_queries.json
    def index
      @title = 'Salesforce Sync Queries'
      @sync_queries = SyncQuery.all
    end
  
    # GET /sf/sync_queries/1
    # GET /sf/sync_queries/1.json
    def show
    end
  
    # GET /sf/sync_queries/new
    # GET /sf/sync_queries/new.json
    def new
      @sync_query = SyncQuery.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @sync_query }
      end
    end
  
    # GET /sf/sync_queries/1/edit
    def edit
    end
  
    # POST /sf/sync_queries
    # POST /sf/sync_queries.json
    def create
      @sync_query = SyncQuery.new(sync_query_params)
  
      respond_to do |format|
        if @sync_query.save
          format.html { redirect_to sync_queries_url, notice: 'Sync query was successfully created.' }
          format.json { render json: @sync_query, status: :created, location: @sync_query }
        else
          format.html { render action: "new" }
          format.json { render json: @sync_query.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /sf/sync_queries/1
    # PUT /sf/sync_queries/1.json
    def update  
      respond_to do |format|
        if @sync_query.update_attributes(sync_query_params)
          format.html { redirect_to sync_queries_url, notice: 'Sync query was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @sync_query.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /sf/sync_queries/1
    # DELETE /sf/sync_queries/1.json
    def destroy
      @sync_query = SyncQuery.find(params[:id])
      @sync_query.destroy
  
      respond_to do |format|
        format.html { redirect_to sync_queries_url }
        format.json { head :no_content }
      end
    end
    
      private
        # Use callbacks to share common setup or constraints between actions.
        
        def sync_sf_to_local(sync_query, sync_fields, remote_sobject, force = false)
          local_object = sync_query.local_model.constantize.find_or_initialize_by(:sf_id => remote_sobject.Id)
          # Sync only if the Salesforce object is newer than the local object 
          unless force == true
            diff = different?(local_object, remote_sobject, sync_fields)
            sf_newer = sobject_newer?(remote_sobject, local_object)
            print "Different? #{diff}\n"
          end
          
          if (diff && sf_newer) || force == true    
          sync_fields.each do |field|
            # Update the local field if it's value is different from the value in Salesforce
            local_object["#{field.local_field_name}"] != remote_sobject["#{field.sf_field_name}"] ? local_object["#{field.local_field_name}"] = remote_sobject["#{field.sf_field_name}"] : nil
            # If Model has a last_sync_at column add the current timestamp
            if local_object.has_attribute?(:last_sync_at) 
             local_object.last_sync_at = Time.now
            end          
          end
          local_object.save(:validate => false) ? puts(local_object.to_s) : 'error' 
          end            
        end
        
        def sync_sf_to_local!(sync_query, sync_fields, remote_sobject)
          sync_sf_to_local(sync_query, sync_fields, remote_sobject, force = true)
        end
        
        def sync_local_to_sf(sync_query, sync_fields, remote_sobject, force = false)
          local_object = sync_query.local_model.constantize.find_by(:sf_id => remote_sobject.Id)          
          # client.update('Account', Id: '0016000000MRatd', Name: 'Whizbang Corp')
          client = Restforce.new
          sync_fields.each do |field|
            # Update the local field if it's value is different from the value in Salesforce
            if local_object["#{field.local_field_name}"] != remote_sobject["#{field.sf_field_name}"]                
               remote_sobject["#{field.sf_field_name}"] = local_object["#{field.local_field_name}"]
               # it's not the most efficient approach, but it is working and also in acceptable spped
               # in order to increase efficiency all field updates could be put into one call.
               client.update(sync_query.sobject, Id: local_object.sf_id, field.sf_field_name => local_object["#{field.local_field_name}"] )
            else
               nil
            end
            # If Model has a last_sync_at column add the current timestamp
            if local_object.has_attribute?(:last_sync_at) 
             local_object.last_sync_at = Time.now
            end          
          end          
        end

        def sync_local_to_sf!(sync_query, sync_fields, remote_sobject)
          sync_local_to_sf(sync_query, sync_fields, remote_sobject, force = true)
        end
                
        def set_sync_query
          @sync_query = SyncQuery.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def sync_query_params
          params.require(:sync_query).permit(:name, :created_filter, :created_operator, :last_modified_filter, :last_modified_operator, :local_model, :sobject, :where_conditions,  :is_primary)
        end
        
        def local_newer? local_object, remote_sobject
          if local_object.updated_at > Time.zone.parse(remote_sobject.LastModifiedDate)
            true
          else
            false
          end          
        end       
        
        def sobject_newer? remote_sobject, local_object
          if local_object.new_record?
            true
          elsif remote_sobject.LastModifiedDate && local_object.last_sync_at
            # Only allow to overwrite local object in case it wasn't updated after last sync
            if local_object.last_sync_at > local_object.updated_at
              Time.zone.parse(remote_sobject.LastModifiedDate) > local_object.updated_at ? true : false
            else
              false
            end
          elsif remote_sobject.LastModifiedDate            
            Time.zone.parse(remote_sobject.LastModifiedDate) > local_object.updated_at ? true : false            
          else
            false
          end      
        end
        
        def merge_values sync_query, remote_sobject, params
          keep_local =  Array.new
          keep_remote = Array.new      
          params.each do |k|        
            if k[1] == 'local'
              keep_local << k[0].delete('sync_field_keep-').to_i
            elsif k[1] == 'remote'
              keep_remote << k[0].delete('sync_field_keep-').to_i
            end
          end
          # "keep local" means update Salesforce with local values
          @keep_local = SyncField.where(:id => keep_local)
            sync_local_to_sf!(sync_query, @keep_local, remote_sobject)          
          # "keep remote" means update local with Salesforce values
          @keep_remote = SyncField.where(:id => keep_remote)
            sync_sf_to_local!(sync_query, @keep_remote, remote_sobject)
          
          # redirect whatever happened
          return "#{keep_local} #{keep_remote}"
        end        
    end  
end
