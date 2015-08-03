require 'active_model'
require 'active_support/core_ext/time/zones'

module Braincert
  class LiveClass
    include ::ActiveModel::Validations
    require_relative 'timezones'

    # attributes auto-assigned by API after creation
    attr_reader :class_id, :user_id, :published
    
    # required attributes on creation
    attr_accessor :title
    attr_accessor :timezone
    attr_accessor :start_time, :end_time
    attr_accessor :date

    # optional attributes on creation
    attr_accessor :currency, :ispaid, :is_recurring, :repeat, :end_classes_count, :end_date, :seat_attendees, :record, :format

    REPEAT_DAILY, REPEAT_MON_THRU_SAT, REPEAT_MON_THRU_FRI, REPEAT_WEEKLY, REPEAT_MONTHLY = *(1..5)

    # attributes that are returned by GETs but don't seem to be specified at creation
    attr_accessor :duration     # in seconds
    attr_accessor :privacy      # 0=public
    attr_accessor :label        # ???
    
    # default values for optional attributes on create
    DEFAULT_ATTRIBUTES = {
      :ispaid => 0,             # not paid (from Braincert point of view)
      :is_recurring => 1,
      :repeat => REPEAT_WEEKLY,
      :end_classes_count => 1,
      :seat_attendees => 25,
      :record => 1,             # 0=don't record
      :format => 'json',
      :privacy => 1
    }

    validates_presence_of :title
    validates_presence_of :timezone
    validates_inclusion_of :timezone, :in => Braincert::Timezones::ZONE_CODES
    validates_format_of :start_time, :with => /\A\d\d:\d\d[AP]M\Z/
    validates_format_of :end_time, :with => /\A\d\d:\d\d[AP]M\Z/
    validates_format_of :date, :with => /\A\d\d\d\d-\d\d-\d\d\Z/

    def initialize(attrs = {})
      @attributes = DEFAULT_ATTRIBUTES.merge(attrs)
    end

    def read_attribute_for_validation(key)
      @attributes[key]
    end
    
    def set_start_time_and_zone(time_with_zone)
      zone_name = time_with_zone.time_zone.name
      localtime = time_with_zone.in_time_zone(zone_name)
      self.timezone = Timezones::ZONES[zone_name]
      self.start_time = localtime.strftime('%I:%M%P')
      self.date = localtime.strftime('%Y-%m-%d')
    end

  end
end
