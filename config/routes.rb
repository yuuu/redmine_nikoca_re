# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :projects do
    resources :niko_faces do
      resources :niko_responses
    end
  end
end
