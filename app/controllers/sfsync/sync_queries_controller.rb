require_dependency "sfsync/application_controller"
module Sfsync
  class SyncQueriesController < ApplicationController
    before_action :set_sync_query, only: [:show, :edit, :update, :destroy]  
    def sync_down
      @sync_query = SyncQuery.find(params[:id])
      if @sync_query.sobject && @sync_query.local_model   
        client = Restforce.new
        sync_fields = Sfsync::SyncField.where(:local_model => @sync_query.local_model)
          .where(:sobject => @sync_query.sobject)
          .where(:sync_query_id => @sync_query.id)          
        query_string = "SELECT Id, #{sync_fields.pluck(:sf_field_name).join(',')} FROM #{@sync_query.sobject} WHERE #{@sync_query.where_conditions}"
        print "SOQL Query: " + query_string
        @remote_sobjects = client.query(query_string)
        @remote_sobjects.each do |remote_sobject|
          sync_object = @sync_query.local_model.constantize.find_or_create_by(:sf_id => remote_sobject.Id)
          sync_fields.each do |field|
            sync_object["#{field.local_field_name}"] != remote_sobject["#{field.sf_field_name}"] ? sync_object["#{field.local_field_name}"] = remote_sobject["#{field.sf_field_name}"] : nil
          end
          sync_object.save(:validate => false) ? puts(sync_object.to_s) : 'error'  
        end
      end
      respond_to do |format|
        format.html { redirect_to sync_queries_url, :notice => 'Synchronized successfully' }
        format.json { head :no_content }
      end
    end
    
    # GET /sf/sync_queries
    # GET /sf/sync_queries.json
    def index
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
        def set_sync_query
          @sync_query = SyncQuery.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def sync_query_params
          params.require(:sync_query).permit(:created_filter, :created_operator, :last_modified_filter, :last_modified_operator, :local_model, :sobject, :where_conditions)
        end
    end  
end
