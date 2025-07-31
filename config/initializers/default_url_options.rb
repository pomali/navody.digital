Rails.application.routes.default_url_options[:host] = ENV.fetch("DEFAULT_URL_HOST", 'localhost:3000')
