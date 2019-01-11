Rails.application.routes.draw do

  get 'acciones', to: 'pumps#acciones', as: :acciones
  get 'definitiva_masiva', to: 'pumps#definitiva_masiva', as: :definitiva_masiva

  resources :pumps do
    collection { post :import }
    #collection { post :buscar }
    get 'definitiva', to: 'pumps#definitiva', as: :definitiva
    get 'detalle', to: 'pumps#detalle', as: :detalle

    resources :tests do
      get 'analisis', to: 'tests#analisis', as: :analisis
      get 'cortada/:n', to: 'tests#cortada', as: :cortada
      get 'guardar', to: 'tests#guardar', as: :guardar
      get 'guardar_igual', to: 'tests#guardar_igual', as: :guardar_igual
      get 'sacar_valida', to: 'tests#sacar_valida', as: :sacar_valida
      get 'entrar_valida', to: 'tests#entrar_valida', as: :entrar_valida
      get 'destroy', to: 'tests#destroy', as: :destroy
      # patch 'cortada/:n', to: 'tests#cortada', as: :cortada
      collection { post :import }

    end
  end

  resources :motors do
    collection { post :import }
  end

  resources :intersections do
    collection { post :import }
  end

  resources :requests do
    get 'aceptar', to: 'requests#aceptar', as: :aceptar
    get 'rechazar', to: 'requests#rechazar', as: :rechazar
  end

  get 'buscar', to: 'pumps#buscar', as: :buscar
  post 'buscar', to: 'pumps#buscar'
  root 'pumps#index'
  devise_for :users
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
