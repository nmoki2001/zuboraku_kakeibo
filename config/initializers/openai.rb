# config/initializers/openai.rb
require "openai"

if ENV["OPENAI_API_KEY"].present?
  OpenAIClient = OpenAI::Client.new(
    api_key: ENV["OPENAI_API_KEY"]
  )
else
  Rails.logger.warn "[OpenAI] OPENAI_API_KEY が設定されていないため、AI分類機能は無効です。"
end
