require 'rails_helper'

describe CreateUserJourney do
  subject { CreateUserJourney.call(user, journey, starting_step).result }

  let!(:user) { create(:user) }
  let!(:journey) { create(:journey) }
  let!(:step1) { create(:step, journey: journey) }
  let!(:task11) { create(:task, step: step1) }
  let!(:step2) { create(:step, journey: journey) }
  let!(:task21) { create(:task, step: step2) }
  let!(:task22) { create(:task, step: step2) }
  let!(:step3) { create(:step, journey: journey) }
  let!(:task31) { create(:task, step: step3) }
  let!(:step4) { create(:step, journey: journey) }
  let!(:task41) { create(:task, step: step4) }

  context 'Starting step is not given' do
    let(:starting_step) { nil }

    it 'Creates new blank user journey' do
      subject

      expect(user.user_journeys.count).to eq 1
      expect(user.user_journeys.last.user_steps).to be_empty
    end

    it 'Returns created journey' do
      expect(subject).to be_a UserJourney
    end
  end

  context 'Starting step is given' do
    let(:starting_step) { step3 }

    it 'Creates new user journey and sets previous steps as completed' do
      subject

      expect(user.user_journeys.count).to eq 1

      # Expect existing steps completed
      journey_steps = user.user_journeys.last.user_steps
      expect(journey_steps.count).to eq 2
      expect(journey_steps.completed.count).to eq 2

      # Expect tasks all completed
      journey_steps.each do |js|
        expect(js.user_tasks.any? { |ut| ut.completed_at.nil? }).to be false
      end
    end
  end

  context 'When given user has started such journey already' do
    let!(:user_journey) { create(:user_journey, user: user, journey: journey, created_at: 1.day.ago) }
    let(:starting_step) { step3 }

    it 'Does not change the existing journey and creates new one' do
      subject

      user_journeys = user.user_journeys.order(:created_at)
      expect(user_journeys.first.user_steps).to be_empty
      expect(user_journeys.last.user_steps.count).to eq 2
    end
  end
end
