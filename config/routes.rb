Sfsync::Engine.routes.draw do
  resources :test_entries
  resources :sobject_fields
  resources :sync_queries do
    member do
      get :sync_down
      get :compare      
      get :resolve      
      post :merge
      delete :polymorphic_delete
    end
  end    
  resources :sync_models do
    member do
      get :sync_down
    end
  end    
  resources :sync_fields do
    collection do 
      get :assign
      put :save_assigned
    end
  end
  resources :sobjects do
    collection do 
      get :sync
    end
  end
end
