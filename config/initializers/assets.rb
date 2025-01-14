# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

Rails.application.config.assets.precompile += ['income_calculator.js']
Rails.application.config.assets.precompile += ['*.png', '*.ico']
Rails.application.config.assets.precompile += ['.svg', '.eot', '.woff', '.ttf']
Rails.application.config.assets.precompile += ['ckeditor/*']
Rails.application.config.assets.precompile += ['chartkick.js']
Rails.application.config.assets.precompile += ['govuk-frontend/all.css']
Rails.application.config.assets.precompile += ['govuk-frontend/all.js']
Rails.application.config.assets.precompile += ['govuk-frontend/all-ie8.css']
Rails.application.config.assets.precompile += ['govuk-fonts/*']
Rails.application.config.assets.precompile += ['images/*']
Rails.application.config.assets.precompile += ['accessible-autocomplete/dist/accessible-autocomplete.min.js']
Rails.application.config.assets.precompile += ['accessible-autocomplete/dist/accessible-autocomplete.min.css']
