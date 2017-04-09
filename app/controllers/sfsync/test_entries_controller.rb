require_dependency "sfsync/application_controller"

module Sfsync
  class TestEntriesController < ApplicationController
    before_action :set_test_entry, only: [:show, :edit, :update, :destroy]

    # GET /test_entries
    def index
      @test_entries = TestEntry.all
    end

    # GET /test_entries/1
    def show
    end

    # GET /test_entries/new
    def new
      @test_entry = TestEntry.new
    end

    # GET /test_entries/1/edit
    def edit
    end

    # POST /test_entries
    def create
      @test_entry = TestEntry.new(test_entry_params)

      if @test_entry.save
        redirect_to @test_entry, notice: 'Test entry was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /test_entries/1
    def update
      if @test_entry.update(test_entry_params)
        redirect_to @test_entry, notice: 'Test entry was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /test_entries/1
    def destroy
      @test_entry.destroy
      redirect_to test_entries_url, notice: 'Test entry was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_test_entry
        @test_entry = TestEntry.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def test_entry_params
        params.require(:test_entry).permit(:name)
      end
  end
end
