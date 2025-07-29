class NewsletterSubscriptionsController < ApplicationController

  def subscribe
    email, altcha = subscription_params
    if AltchaSolution.verify_and_save(altcha)
      begin
        SubscribeToNewsletterJob.perform_now(email, 'NewsletterSubscription')
        respond_to do |format|
          format.js { render :success}
        end
      rescue => e
        respond_to do |format|
          format.js { render :subscription_failure, status: :bad_request }
        end
      end
    else
      respond_to do |format|
        format.js { render :altcha_failure, status: :unprocessable_entity}
      end
    end
  end

  def confirmed
    return redirect_to root_path, alert: 'Neplatný odkaz na potvrdenie newslettra' unless params[:token].present?

    begin
      token_data = Rails.application.message_verifier(:newsletter_confirmation).verify(params[:token])

      if token_data.is_a?(Hash) && token_data[:expires_at]
        if Time.current.to_i > token_data[:expires_at]
          redirect_to root_path, alert: 'Platnosť odkazu na potvrdenie newslettra vypršala'
          return
        end
      end

      render :confirmed
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to root_path, alert: 'Neplatný odkaz na potvrdenie newslettra'
    end
  end

  private

  def subscription_params
    params.require([:email, :altcha])
  end
end
