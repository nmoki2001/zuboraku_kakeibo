Rails.application.routes.draw do
  get "analysis/show"

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "entries#new"

  resources :entries, only: [:new, :create, :edit, :update]
  resource  :analysis, only: :show, controller: :analysis

  # ▼ ここを追加（その他画面）
  get "others", to: "others#show", as: :others
end
