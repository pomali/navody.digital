class CreateUserJourney < Patterns::Service

  def initialize(user, journey, starting_step)
    @user = user
    @journey = journey
    @starting_step = starting_step
  end

  def call
    build_completed_user_steps if starting_step.present?
    new_user_journey.save!
    new_user_journey
  end

  private

  attr_reader :user, :journey, :starting_step

  def existing_user_journey
    @existing_user_journey ||= user.user_journeys.find_by(journey: journey)
  end

  def new_user_journey
    @new_user_journey ||= user.user_journeys.new(journey: journey)
  end

  def build_completed_user_steps
    current_time = Time.now

    journey.steps.where('position < ?', starting_step.position).each do |step|
      user_step = new_user_journey.user_steps.completed.build(step: step)

      step.tasks.each do |task|
        user_step.user_tasks.build(task: task, completed_at: current_time)
      end
    end
  end
end
