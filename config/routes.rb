Rails.application.routes.draw do
  resources :pumps do
    collection { post :import }
  	resources :tests do
  		get 'analisis', to: 'tests#analisis', as: :analisis
      get 'cortada/:n', to: 'tests#cortada', as: :cortada
      # patch 'cortada/:n', to: 'tests#cortada', as: :cortada
      collection { post :import }

  	end
  end

  root 'pumps#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
