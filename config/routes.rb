Rails.application.routes.draw do
  resources :pumps do
    collection { post :import }
    collection { post :buscar }
    #get 'busqueda', to: 'pumps#busqueda', as: :busqueda
    get 'definitiva', to: 'pumps#definitiva', as: :definitiva
    get 'detalle', to: 'pumps#detalle', as: :detalle

  	resources :tests do
  		get 'analisis', to: 'tests#analisis', as: :analisis
      get 'cortada/:n', to: 'tests#cortada', as: :cortada
      get 'guardar', to: 'tests#guardar', as: :guardar
      get 'guardar_igual', to: 'tests#guardar_igual', as: :guardar_igual
      get 'sacar_valida', to: 'tests#sacar_valida', as: :sacar_valida
      get 'entrar_valida', to: 'tests#entrar_valida', as: :entrar_valida
      # patch 'cortada/:n', to: 'tests#cortada', as: :cortada
      collection { post :import }

  	end
  end

  resources :pumps do
    get 'busqueda' ,to: 'pumps#busqueda', as: :busqueda
  end

  #get 'busqueda', to: 'application#busqueda', as: :busqueda 

  root 'pumps#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
