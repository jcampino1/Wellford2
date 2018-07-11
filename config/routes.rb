Rails.application.routes.draw do
  resources :pumps do
    collection { post :import }
  	resources :tests do
  		get 'analisis', to: 'tests#analisis', as: :analisis
      collection { post :import }
      collection { post :cortada }

  	end
  end

  root 'pumps#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
