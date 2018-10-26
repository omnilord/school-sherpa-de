Rails.application.routes.draw do
  root 'pages#index'
  get '/lookup' => 'patterns#lookup'
end
