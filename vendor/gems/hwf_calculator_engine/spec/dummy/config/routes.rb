Rails.application.routes.draw do

  mount HwfCalculatorEngine::Engine => "/api/calculator"
end
