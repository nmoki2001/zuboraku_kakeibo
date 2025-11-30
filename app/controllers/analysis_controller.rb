class AnalysisController < ApplicationController
  def show
    @entries = Entry.order(occurred_on: :asc)

    # ひとまずダミー文言
    @good_point    = "先月より食費が10%減少"
    @improve_point = "交際費がかさみがち"
  end
end
