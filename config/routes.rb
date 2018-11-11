Rails.application.routes.draw do
  root 'pages#index'
  get '/lookup' => 'patterns#lookup'
  get '/radius' => 'patterns#radius'
  get '/feeders' => 'patterns#feeders'
end
