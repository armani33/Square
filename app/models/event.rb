class Event < ActiveRecord::Base
  default_scope -> { order(date: :asc) }
  mount_uploader :picture, PictureUploader
  belongs_to :user
  has_many :passive_attends, class_name: "Attend", foreign_key: "attended_event_id", dependent: :destroy
  has_many :attendees, through: :passive_attends, source: :attendee
  has_many :comments, dependent: :destroy
  validates :title, presence: true, length: {maximum: 100}
  validates :description, presence: true, length: {maximum: 1000}
  validates :category_id, presence: true
  validate  :picture_size
  after_validation :normalize_title
  by_star_field :date

  def Event.upcoming
    Event.after(Time.now)
    # Event.all.where("date > ?", Time.now)
  end

  def Event.past
    Event.before(Time.now)
    # Event.all.where("date < ?", Time.now)
  end


  def has_valid_date?
    self.date < Time.now.advance(days: 1) ? false : true
  end

  def Event.search(params)
    params[:category].to_i != 0 ? events = Event.where(category_id: params[:category].to_i ) : events = Event.all
    events = events.where("lower(title) LIKE ? or lower(description) LIKE ?", "%#{params[:search].downcase}%", "%#{params[:search.downcase].downcase}%") if params[:search].present?

    if params[:timeline].nil?
      events = events.upcoming
    else
      events = events.past if params[:timeline] == "Past Events"
      events = events.upcoming if params[:timeline] == "Any Day"
      events = events.tomorrow if params[:timeline] == "Tomorrow"
      events = events.today if params[:timeline] == "Today"
      events = events.yesterday if params[:timeline] == "Yesterday"
      events = events.by_weekend if params[:timeline] == "This Weekend"
    end

    if params[:start_date] && params[:end_date]
      start_date = params[:start_date]
      end_date = params[:end_date]
      events = events.between_dates(start_date, end_date)
    end
    return events
  end

private

  # Validates the size of an uploaded picture.
  def picture_size
    if picture.size > 5.megabytes
      errors.add(:picture, "should be less than 5MB")
    end
  end

  def normalize_title
    self.title = title.downcase.titleize
  end

end
