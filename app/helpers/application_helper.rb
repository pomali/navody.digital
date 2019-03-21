module ApplicationHelper
  def build_page_title(title, category = nil)
    [title, category, 'Návody.Digital'].compact.join(' | ')
  end

  def start_journey_link(journey, step = nil)
    data = {}
    if step.present? && step.position > 1
      data[:confirm] = 'Toto nie je začiatok návodu. Chcete začať vybavovať v tomto kroku?'
    end

    link_to 'Začať vybavovať',
        start_user_journey_path(journey, step: step&.slug),
        class: 'sdn-headline__button govuk-button',
        method: :post,
        data: data
  end
end
