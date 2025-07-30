require 'rails_helper'

RSpec.describe SubscribeToNewsletterWithDoiJob, type: :job do
  describe '#perform_now' do
    it 'calls APIs' do
      expect(EmailService).to receive(:find_list).with('list-name').and_return(id: '34')
      expect(EmailService).to receive(:create_doi_contact).with(
        email: 'email',
        include_list_ids: ['34']
      )
      described_class.perform_now('email', 'list-name')
    end

    context 'list not found' do
      it 'raises exception' do
        expect(EmailService).to receive(:find_list).with('list-name').and_return(nil)
        expect{
          described_class.perform_now('email', 'list-name')
        }.to raise_error(StandardError)
      end
    end
  end
end
