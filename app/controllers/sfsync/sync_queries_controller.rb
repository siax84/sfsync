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
        # In order to not run into problems when synchronizing BLOB fields, we split the Query into batches of 100
        # In order to not run into the Maximum Offset limit, we create the batches based on the CreatedDate
        puts query = "SELECT COUNT() FROM #{@sync_query.sobject} WHERE #{@sync_query.where_conditions}"
        result_count = client.query(query).size if @sync_query.query_all == false
        result_count = client.query_all(query).size if @sync_query.query_all == true
        
        created_date = "1970-01-01T00:00:00.000+0000" 
        (1..result_count).each_slice @sync_query.batch_size do |slice|    
          query_string = "SELECT Id, #{sync_fields.pluck(:sf_field_name).join(',')}, CreatedDate FROM #{@sync_query.sobject} WHERE #{@sync_query.where_conditions} AND CreatedDate > #{created_date} ORDER BY CreatedDate LIMIT 1000"        
          print "SOQL Query: " + query_string
          
          @remote_sobjects = client.query(query_string) if @sync_query.query_all == false
          @remote_sobjects = client.query_all(query_string) if @sync_query.query_all == true
                    
          created_date = @remote_sobjects.entries.last.CreatedDate if @remote_sobjects.entries.any?
          print "CREATED: " + created_date
          @local_objects = @sync_query.local_model.constantize.where(:sf_id => @remote_sobjects.map(&:Id))
          @remote_sobjects.each do |remote_sobject|
            sync_sf_to_local(@sync_query, sync_fields, remote_sobject, params[:force] == 'true' ? true : false)
          end 
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
      
      @sync_query = SyncQuery.find(params[:id])      
      
      if @sync_query.sobject && @sync_query.local_model        
        @local_object = @sync_query.local_model.constantize.find_by_id(local_object_id)
        client = Restforce.new
        
        @sync_fields = @sync_query.current_sync_fields    
        
        if @local_object.in_sf?         
          # we need to make sure that we have lastModiefiedDate for comparison of the objects, but if it was already mapped to a field it would occur twice in the SOQL query
          if @sync_fields.pluck(:sf_field_name).include? 'LastModifiedDate'          
            query_string = "SELECT Id, #{@sync_fields.pluck(:sf_field_name).join(',')} FROM #{@sync_query.sobject} WHERE Id = '#{@local_object.sf_id}'"
          else
            query_string = "SELECT Id, LastModifiedDate, #{@sync_fields.pluck(:sf_field_name).join(',')} FROM #{@sync_query.sobject} WHERE Id = '#{@local_object.sf_id}'"
          end        
          
          print "SOQL Query: " + query_string
                  
          @remote_object = client.query_all(query_string).first          
          @diff = different? @local_object, @remote_object, @sync_fields
        else
          @diff_fields = Array.new
          @remote_object = client.describe('Account')
        end
        render :layout => false
      end
      
    end
    
    def merge      
      local_object_id = params[:local_object_id]
      @sync_query = SyncQuery.find(params[:id])      

      if @sync_query.sobject && @sync_query.local_model
        # @local_objects needs to be present for sync_sf_to_local
        @local_objects = @sync_query.local_model.constantize.where(id: local_object_id)
        @local_object = @local_objects.first 
        client = Restforce.new
        
        if @local_object.in_sf?
          @sync_fields = @sync_query.current_sync_fields    
          
          # we need to make sure that we have lastModiefiedDate for comparison of the objects, but if it was already mapped to a field it would occur twice in the SOQL query
          if @sync_fields.pluck(:sf_field_name).include? 'LastModifiedDate'          
            query_string = "SELECT Id, #{@sync_fields.pluck(:sf_field_name).join(',')} FROM #{@sync_query.sobject} WHERE Id = '#{@local_object.sf_id}'"
          else
            query_string = "SELECT Id, LastModifiedDate, #{@sync_fields.pluck(:sf_field_name).join(',')} FROM #{@sync_query.sobject} WHERE Id = '#{@local_object.sf_id}'"
          end        
          
          print "SOQL Query: " + query_string
          
          @remote_object = client.query(query_string).first if @sync_query.query_all == false
          @remote_object = client.query_all(query_string).first if @sync_query.query_all == true
        end
      end
      
      if params[:merge] == 'true'
        begin 
          flash[:notice] = merge_values @sync_query, @remote_object, @local_object, params
        rescue => error
          @errors = Array.new
          @errors << error
        end       
      end
      
      respond_with @sync_query do |format|
        format.js { render :layout => false }
      end         
    end
    
    def resolve
      @title = 'Records different than in Salesforce'
      @sync_query = Sfsync::SyncQuery.find(params[:id])
      @has_affiliate = @sync_query.local_model.constantize.reflect_on_association(:affiliate)
      if @sync_query.sobject && @sync_query.local_model   
            client = Restforce.new
            sync_fields = Sfsync::SyncField.where(:local_model => @sync_query.local_model)
              .where(:sobject => @sync_query.sobject)
              .where(:sync_query_id => @sync_query.id)          
            if sync_fields.pluck(:sf_field_name).include? 'LastModifiedDate'              
              query_string = "SELECT Id, #{sync_fields.pluck(:sf_field_name).join(',')} FROM #{@sync_query.sobject} WHERE #{@sync_query.where_conditions}"
            else
              query_string = "SELECT Id, LastModifiedDate, #{sync_fields.pluck(:sf_field_name).join(',')} FROM #{@sync_query.sobject} WHERE #{@sync_query.where_conditions}"
            end
            print "SOQL Query: " + query_string
            
            @remote_sobjects = client.query(query_string)  if @sync_query.query_all == false
            @remote_sobjects = client.query_all(query_string) if @sync_query.query_all == true
      end
      @list = Array.new
      # Check if Object has a parent affiliate
      if @has_affiliate
        @local_objects = @sync_query.local_model.constantize.where(sf_id: @remote_sobjects.map(&:Id)).includes(:affiliate).order(created_at: :desc)
      else
        @local_objects = @sync_query.local_model.constantize.where(sf_id: @remote_sobjects.map(&:Id)).order(created_at: :desc)
      end
      @remote_sobjects.each do |remote_sobject|
        select_object = @local_objects.select {|lo| lo.sf_id == remote_sobject.Id} 
        if select_object.any?
          local_object = select_object.first
          diff = different?(local_object, remote_sobject, sync_fields)
        end
        if diff == true
          @list << [local_object, @diff_fields, remote_sobject.LastModifiedDate]        
        end
      end
      if @has_affiliate
        @new_local_objects = @sync_query.local_model.constantize.where("sf_id LIKE 'signup-%' OR sf_id IS NULL").includes(:affiliate).order(created_at: :desc)
      else
        @new_local_objects = @sync_query.local_model.constantize.where("sf_id LIKE 'signup-%' OR sf_id IS NULL").order(created_at: :desc)
      end
      @new_local_objects.each do |new_object|
        @list << [new_object, 'Not in Salesforce']
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
      @title = 'Create Salesforce Sync Query'      
      @sync_query = SyncQuery.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @sync_query }
      end
    end
  
    # GET /sf/sync_queries/1/edit
    def edit
      @title = 'Edit Salesforce Sync Query'
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
    
    def polymorphic_delete
      if params[:class]
        object = params[:class].constantize
        #object.find(])
        object.delete params[:id]
  
      respond_to do |format|
        format.html { redirect_to :back }
        format.js { render :layout => false }
      end
      end
    end
    
      private
        # Use callbacks to share common setup or constraints between actions.
        
        def sync_sf_to_local(sync_query, sync_fields, remote_sobject, force = false)
          # local_object = sync_query.local_model.constantize.find_or_initialize_by(:sf_id => remote_sobject.Id)
          select_object = @local_objects.select {|lo| lo.sf_id == remote_sobject.Id} 
          if select_object.empty?
            local_object = sync_query.local_model.constantize.new(:sf_id => remote_sobject.Id)
          else
            local_object = select_object.first
          end
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
              if local_object.has_attribute?(:last_sync_at) && local_object.has_changes_to_save?
              local_object.last_sync_at = Time.now
              end          
            end
            if local_object.has_changes_to_save?
            local_object.save(:validate => false) ? puts(local_object.to_s) : 'error' 
            end
          end            
        end
        
        def sync_sf_to_local!(sync_query, sync_fields, remote_sobject)
          sync_sf_to_local(sync_query, sync_fields, remote_sobject, force = true)
        end
        
        def sync_local_to_sf(sync_query, sync_fields, local_object, force = false)
          #local_object = sync_query.local_model.constantize.find_by(:sf_id => remote_sobject.Id)          
          # client.update('Account', Id: '0016000000MRatd', Name: 'Whizbang Corp')
          client = Restforce.new
               
          args = Hash.new             
          sync_fields.each { |field| args.store field.sf_field_name, local_object["#{field.local_field_name}"]}          
          puts args
          if local_object.in_sf?
            args.store "Id", local_object.sf_id               
            client.update(sync_query.sobject, args )
          else            
            sf_id = client.create!(sync_query.sobject, args )
            local_object.update_attribute(:sf_id, sf_id)
          end   
        end       

        def sync_local_to_sf!(sync_query, sync_fields, local_object)
          sync_local_to_sf(sync_query, sync_fields, local_object, force = true)
        end
                
        def set_sync_query
          @sync_query = SyncQuery.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def sync_query_params
          params.require(:sync_query).permit(:name, :created_filter, :created_operator, :last_modified_filter, :last_modified_operator, :local_model, :sobject, :where_conditions,  :is_primary, :query_all, :batch_size)
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
          elsif remote_sobject.LastModifiedDate && local_object.has_attribute?(:last_sync_at)
            # Only allow to overwrite local object in case it wasn't updated after last sync
            if local_object.last_sync_at.nil?
              true
            elsif local_object.last_sync_at > local_object.updated_at
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
        
        def merge_values sync_query, remote_sobject, local_object, params
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
          if @keep_local.any?
            sync_local_to_sf!(sync_query, @keep_local, local_object)
            puts "LOCAL #{@keep_local}"          
          end
          # "keep remote" means update local with Salesforce values
          @keep_remote = SyncField.where(:id => keep_remote)
          if @keep_remote.any?
            sync_sf_to_local!(sync_query, @keep_remote, remote_sobject)
            puts "REMOTE #{@keep_remote}"
          end
          # redirect whatever happened
          return "#{keep_local} #{keep_remote}"
        end        
    end  
end
