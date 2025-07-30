class EmailService
  class << self
    def subscribe_to_newsletter(email, list_name)
      list = find_list(list_name)

      raise "Contact list not found: #{list_name}" unless list[:id]

      create_doi_contact(email: email, include_list_ids: [list[:id]])
    end

    def send_email(params)
      email = Brevo::SendSmtpEmail.new(params)
      transactional_emails_api.send_transac_email(email)
    end

    def create_doi_contact(params)
      raise ArgumentError, "Email is required" if params[:email].blank?
      raise ArgumentError, "Include list IDs are required" if params[:include_list_ids].blank?

      host = Rails.application.routes.default_url_options[:host] || 'localhost:3000'
      protocol = Rails.application.config.force_ssl ? 'https' : 'http'
      redirection_url = "#{protocol}://#{host}/newsletter/confirmed"

      doi_contact = Brevo::CreateDoiContact.new
      doi_contact.email = params[:email]
      doi_contact.include_list_ids = params[:include_list_ids]
      doi_contact.template_id = doi_template_id
      doi_contact.redirection_url = redirection_url

      contacts_api.create_doi_contact(doi_contact)
    end

    private

    def doi_template_id
      Rails.application.config_for(:auth).dig(:brevo, :doi_template_id)
    end

    def create_contact(params)
      contacts_api.create_contact(params)
    end

    def find_list(name)
      options = {
        limit: 50,
        offset: 0
      }
      result = contacts_api.get_lists(options)
      total_pages = (result.count / options[:limit]) + 1

      total_pages.times do |n|
        matched = result.lists.detect { |i| i[:name] == name }
        return matched if matched
        return if (n + 1) == total_pages

        options[:offset] = (n + 1) * options[:limit]
        result = contacts_api.get_lists(options)
      end
    end

    def contacts_api
      Brevo::ContactsApi.new
    end

    def transactional_emails_api
      Brevo::TransactionalEmailsApi.new
    end
  end
end
