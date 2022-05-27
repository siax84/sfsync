require 'test_helper'

module Sfsync
  class TestEntriesControllerTest < ActionController::TestCase
    setup do
      @test_entry = sfsync_test_entries(:one)
      @routes = Engine.routes
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:test_entries)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create test_entry" do
      assert_difference('TestEntry.count') do
        post :create, test_entry: { name: @test_entry.name }
      end

      assert_redirected_to test_entry_path(assigns(:test_entry))
    end

    test "should show test_entry" do
      get :show, id: @test_entry
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @test_entry
      assert_response :success
    end

    test "should update test_entry" do
      patch :update, id: @test_entry, test_entry: { name: @test_entry.name }
      assert_redirected_to test_entry_path(assigns(:test_entry))
    end

    test "should destroy test_entry" do
      assert_difference('TestEntry.count', -1) do
        delete :destroy, id: @test_entry
      end

      assert_redirected_to test_entries_path
    end
  end
end
