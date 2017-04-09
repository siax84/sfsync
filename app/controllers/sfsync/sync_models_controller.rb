require_dependency "sfsync/application_controller"
module Sfsync
  class SyncModelsController < ApplicationController
  
    def sync_down
      @sync_model = SyncModel.find(params[:id])
      if params[:sobject]    
        client = Restforce.new
        sobject = params[:sobject]
        sync_fields = SyncField.where(:local_model => @sync_model.model_name).where(:sobject => sobject)
        @remote_sobjects = client.query("SELECT Id, #{sync_fields.pluck(:sf_field_name).join(',')} FROM #{sobject} WHERE #{params['soql_where']}")
        @remote_sobjects.each do |remote_sobject|
          sync_object = @sync_model.model_name.constantize.find_or_create_by_sf_id(remote_sobject.Id)
          sync_fields.each do |field|
            sync_object["#{field.local_field_name}"] != remote_sobject["#{field.sf_field_name}"] ? sync_object["#{field.local_field_name}"] = remote_sobject["#{field.sf_field_name}"] : nil
          end
          sync_object.save(:validate => false) ? puts(sync_object.to_s) : 'error'  
        end
      end
      respond_to do |format|
        format.html {render :layout => 'one_column' }
      end
    end  
    
    # GET /sf/sync_models
    # GET /sf/sync_models.json
    def index
      @sync_models = SyncModel.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @sync_models }
      end
    end
  
    # GET /sf/sync_models/1
    # GET /sf/sync_models/1.json
    def show
      @sync_model = SyncModel.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @sync_model }
      end
    end
  
    # GET /sf/sync_models/new
    # GET /sf/sync_models/new.json
    def new
      @sync_model = SyncModel.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @sync_model }
      end
    end
  
    # GET /sf/sync_models/1/edit
    def edit
      @sync_model = SyncModel.find(params[:id])
    end
  
    # POST /sf/sync_models
    # POST /sf/sync_models.json
    def create
      @sync_model = SyncModel.new(sync_model_params)
  
      respond_to do |format|
        if @sync_model.save
          format.html { redirect_to @sync_model, notice: 'Sync model was successfully created.' }
          format.json { render json: @sync_model, status: :created, location: @sync_model }
        else
          format.html { render action: "new" }
          format.json { render json: @sync_model.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /sf/sync_models/1
    # PUT /sf/sync_models/1.json
    def update
      @sync_model = SyncModel.find(params[:id])
  
      respond_to do |format|
        if @sync_model.update_attributes(sync_model_params)
          format.html { redirect_to @sync_model, notice: 'Sync model was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @sync_model.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /sf/sync_models/1
    # DELETE /sf/sync_models/1.json
    def destroy
      @sync_model = SyncModel.find(params[:id])
      @sync_model.destroy
  
      respond_to do |format|
        format.html { redirect_to sync_models_url }
        format.json { head :no_content }
      end
    end
      private
        # Use callbacks to share common setup or constraints between actions.
        def set_sync_model
          @sync_model = SyncModel.find(params[:id])
        end
  
        # Only allow a trusted parameter "white list" through.
        def sync_model_params
          params.require(:sync_model).permit(:local_name)
        end
    end  
end
