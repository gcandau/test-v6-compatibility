# frozen_string_literal: true

Rails.application.routes.draw do
  match 'redmineup/settings/:id', to: 'redmineup#settings', as: 'redmineup_settings', via: [:get, :post]
end
