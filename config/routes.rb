Bskb::Application.routes.draw do

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
   #root 'home#index'
  root :to => 'home#testform'
  
  captcha_route

  get 'errors' => 'errors#index'

  resources :home  do
    collection do
      get :testform
      post :testform
    end
  end

  resources :users  do
    collection do
      get :sign_in, :sign_up, :sign_out, :forgot_password
      post :login
    end
  end

  resources :sessions, :only => [:new, :create, :destroy]

# 后台begin
  namespace :kobe do
    resources :main, :only => :index do
      collection do
        get :to_do
      end
    end
    resources :departments
    resources :articles do 
      collection do
        post :batch_task
      end
    end
    resources :categorys, :only => :index do
      collection do
        get :category_json
      end
    end
    resources :menus do
      collection do
        get :ztree
        post :move
      end
    end
    resources :users, :except => :index do 
      collection do
        get :profile, :change_password, :setting
      end
    end
    resources :categories, :except => :show do
      collection do
        get :ztree, :set_params
        post :move, :save_params, :save_attr, :remove_params
      end
    end
  end
# 后台end

  resources :shared do
    collection do
      delete :department, :area
      get :department, :area
    end
  end

  resources :kobe, :only => :index do
    collection do
      get :search, :obj_class_json
    end
  end

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
