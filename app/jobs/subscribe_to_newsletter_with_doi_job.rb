class SubscribeToNewsletterWithDoiJob < ApplicationJob
  queue_as :default

  def perform(email, list_name)
    EmailService.subscribe_to_newsletter_with_doi(email, list_name)
  end
end
