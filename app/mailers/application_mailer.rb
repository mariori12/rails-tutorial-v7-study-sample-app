# frozen_string_literal: true

# ApplicationMailer serves as the base class for all mailers in the application.
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
