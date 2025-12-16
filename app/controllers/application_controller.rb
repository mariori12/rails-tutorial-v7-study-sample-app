# frozen_string_literal: true

# ApplicationController is the base controller for all application controllers.
class ApplicationController < ActionController::Base
  def hello
    render html: 'hello, world!'
  end
end
