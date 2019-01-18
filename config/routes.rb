Rails.application.routes.draw do
  root 'pages#index'

  # Static
  get '/learn' => 'pages#learn'
  get '/search' => 'pages#search'
  get '/apply' => 'pages#apply'

  # Dynamic
  get '/lookup' => 'patterns#lookup'
  get '/radius' => 'patterns#radius'
  get '/district' => 'patterns#district'
end
