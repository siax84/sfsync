require_dependency "sfsync/application_controller"
module Sfsync
  class SyncFieldsController < ApplicationController
    def assign
      @local_model = params[:local_model]
      @available_fields = SobjectField.where(:sobject_name => params[:sobject]).order(:name)   
      @sync_fields = SyncField.where(:sobject => params[:sobject]).where(:sync_query_id => params[:sync_query_id])       
      respond_to do |format|
        format.html
      end
    end
  
    def save_assigned
      sobject = params[:sobject]
      params[:index].each do |index|
        index = index.to_i
        sync_field = SyncField.find_or_create_by(
          :sobject => sobject,
          :sync_query_id => params[:sync_query_id],
          :local_model => params[:local_model],
          :sf_field_name => params[:sf_field_names][index]
          )      
        if params[:local_field_names][index].blank?
          sync_field.delete
        else  
          sync_field.local_field_name = params[:local_field_names][index]
          sync_field.save 
        end
      end
      
      respond_to do |format|
        format.html { redirect_to sync_queries_path, notice: 'Setup completed.'}
        format.json { head :no_content }
      end
    end  
    
    # GET /sf/sync_fields
    # GET /sf/sync_fields.json
    def index
      @sync_fields = SyncField.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @sync_fields }
      end
    end
  
    # GET /sf/sync_fields/1
    # GET /sf/sync_fields/1.json
    def show
      @sync_field = SyncField.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @sync_field }
      end
    end
  
    # GET /sf/sync_fields/new
    # GET /sf/sync_fields/new.json
    def new
      @sync_field = SyncField.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @sync_field }
      end
    end
  
    # GET /sf/sync_fields/1/edit
    def edit
      @sync_field = SyncField.find(params[:id])
    end
  
    # POST /sf/sync_fields
    # POST /sf/sync_fields.json
    def create
      @sync_field = SyncField.new(params[:sync_field])
  
      respond_to do |format|
        if @sync_field.save
          format.html { redirect_to @sync_field, notice: 'Sync field was successfully created.' }
          format.json { render json: @sync_field, status: :created, location: @sync_field }
        else
          format.html { render action: "new" }
          format.json { render json: @sync_field.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /sf/sync_fields/1
    # PUT /sf/sync_fields/1.json
    def update
      @sync_field = SyncField.find(params[:id])
  
      respond_to do |format|
        if @sync_field.update_attributes(params[:sync_field])
          format.html { redirect_to @sync_field, notice: 'Sync field was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @sync_field.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /sf/sync_fields/1
    # DELETE /sf/sync_fields/1.json
    def destroy
      @sync_field = SyncField.find(params[:id])
      @sync_field.destroy
  
      respond_to do |format|
        format.html { redirect_to sync_fields_url }
        format.json { head :no_content }
      end
    end
    
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_sync_field
          @sync_field = SyncField.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def sync_field_params
          params.require(:sync_field).permit(:local_field_name, :local_model, :sf_field_name, :sobject)
        end
    end    
end
