Rails.application.routes.draw do
  root 'pages#index'
  get '/lookup' => 'patterns#lookup'
  get '/radius' => 'patterns#radius'
  get '/district' => 'patterns#district'
end
