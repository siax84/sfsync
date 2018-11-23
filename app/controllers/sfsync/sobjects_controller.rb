require_dependency "sfsync/application_controller"

module Sfsync
  class SobjectsController < ApplicationController
    
    def sync
      client = Restforce.new
      if params[:sobject]
        sobjects = ["#{params[:sobject]}"]
      else 
        sobjects = client.list_sobjects
      end 
      sobjects.each do |sobject|
        sobject_in_db = Sfsync::Sobject.find_or_initialize_by(:name => sobject)
        attributes = client.describe(sobject)      
        attributes.each do |key_value|
          unless ['fields', 'childRelationships', 'recordTypeInfos', 'urls', 'actionOverrides', 'compactLayoutable', 
            'namedLayoutInfos', 'encrypted'].include?(key_value[0])
            sobject_in_db["#{key_value[0].underscore}"] = key_value[1] 
          end          
        end
        sobject_in_db.save
        attributes.fields.each do |field|
          field_in_db = Sfsync::SobjectField.find_or_initialize_by(:sobject_name => sobject, :name => field.name)
          field.each do |key_value|
            unless ['picklistValues', 'referenceTo', 'encrypted', 'extraTypeInfo', 'filteredLookupInfo', 'mask', 'maskType', 'queryByDistance', 'referenceTargetField'].include?(key_value[0])
              field_in_db["#{key_value[0].underscore}"] = key_value[1] 
            end
          end
        field_in_db.save          
        end
      end
      respond_to do |format|
        format.html { redirect_to sobjects_url, notice: 'Sync successful.'}
        format.json { head :no_content }
      end
    end 
    # GET /sf/sobjects
    # GET /sf/sobjects.json
    def index
      @title = 'Salesforce Objects'
      @sf_sobjects = Sfsync::Sobject.order(:label).all
  
      respond_to do |format|
        format.html
        format.json { render json: @sf_sobjects }
      end
    end
  
    # GET /sf/sobjects/1
    # GET /sf/sobjects/1.json
    def show
      @sf_sobject = Sfsync::Sobject.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @sf_sobject }
      end
    end
  
    # GET /sf/sobjects/new
    # GET /sf/sobjects/new.json
    def new
      @sf_sobject = Sfsync::Sobject.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @sf_sobject }
      end
    end
  
    # GET /sf/sobjects/1/edit
    def edit
      @sf_sobject = Sfsync::Sobject.find(params[:id])
    end
  
    # POST /sf/sobjects
    # POST /sf/sobjects.json
    def create
      @sf_sobject = Sfsync::Sobject.new(params[:sf_sobject])
  
      respond_to do |format|
        if @sf_sobject.save
          format.html { redirect_to @sf_sobject, notice: 'Sobject was successfully created.' }
          format.json { render json: @sf_sobject, status: :created, location: @sf_sobject }
        else
          format.html { render action: "new" }
          format.json { render json: @sf_sobject.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /sf/sobjects/1
    # PUT /sf/sobjects/1.json
    def update
      @sf_sobject = Sfsync::Sobject.find(params[:id])
  
      respond_to do |format|
        if @sf_sobject.update_attributes(params[:sf_sobject])
          format.html { redirect_to @sf_sobject, notice: 'Sobject was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @sf_sobject.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /sf/sobjects/1
    # DELETE /sf/sobjects/1.json
    def destroy
      @sf_sobject = Sfsync::Sobject.find(params[:id])
      @sf_sobject.destroy
  
      respond_to do |format|
        format.html { redirect_to sf_sobjects_url }
        format.json { head :no_content }
      end
    end
    
    def resource_params
      params.require(:sobject).permit!
    end
  end
end