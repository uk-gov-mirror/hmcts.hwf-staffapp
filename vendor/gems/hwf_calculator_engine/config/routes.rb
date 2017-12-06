HwfCalculatorEngine::Engine.routes.draw do
  post '/calculation' => 'calculations#create'
end
