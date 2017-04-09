require_dependency "sfsync/application_controller"
module Sfsync
  class SobjectFieldsController < ApplicationController
  
    # GET /sf/sobject_fields
    # GET /sf/sobject_fields.json
    def index
      @sobject_fields = SobjectField.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @sobject_fields }
      end
    end
  
    # GET /sf/sobject_fields/1
    # GET /sf/sobject_fields/1.json
    def show
      @sobject_field = SobjectField.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @sobject_field }
      end
    end
  
    # GET /sf/sobject_fields/new
    # GET /sf/sobject_fields/new.json
    def new
      @sobject_field = SobjectField.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @sobject_field }
      end
    end
  
    # GET /sf/sobject_fields/1/edit
    def edit
      @sobject_field = SobjectField.find(params[:id])
    end
  
    # POST /sf/sobject_fields
    # POST /sf/sobject_fields.json
    def create
      @sobject_field = SobjectField.new(params[:sobject_field])
  
      respond_to do |format|
        if @sobject_field.save
          format.html { redirect_to @sobject_field, notice: 'Sobject field was successfully created.' }
          format.json { render json: @sobject_field, status: :created, location: @sobject_field }
        else
          format.html { render action: "new" }
          format.json { render json: @sobject_field.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /sf/sobject_fields/1
    # PUT /sf/sobject_fields/1.json
    def update
      @sobject_field = SobjectField.find(params[:id])
  
      respond_to do |format|
        if @sobject_field.update_attributes(params[:sobject_field])
          format.html { redirect_to @sobject_field, notice: 'Sobject field was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @sobject_field.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /sf/sobject_fields/1
    # DELETE /sf/sobject_fields/1.json
    def destroy
      @sobject_field = SobjectField.find(params[:id])
      @sobject_field.destroy
  
      respond_to do |format|
        format.html { redirect_to sobject_fields_url }
        format.json { head :no_content }
      end
    end
    
    def resource_params
      params.require(:sobject_field).permit!
    end
        
  end
end