class PagesController < ApplicationController
  def index
    @events = Event.upcoming.all
  end

  def about
  end
end
