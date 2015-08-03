require 'active_model'
require 'active_support/core_ext/time/zones'

module Braincert
  class LiveClass
    require_relative 'timezones'

    include ActiveModel::Validations
    include ActiveModel::Serialization

    # Public attributes auto-assigned by API after creation
    attr_reader :class_id, :user_id, :published
    
    # Public required attributes on creation
    attr_accessor :title
    attr_accessor :timezone
    attr_accessor :start_time, :end_time
    attr_accessor :date

    # Optional attributes on creation
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
      DEFAULT_ATTRIBUTES.merge(attrs).each_pair { |k,v| self.send("#{k}=", v) }
    end

    # def read_attribute_for_validation(key)
    #   @attributes[key]
    # end

    # def 

    # public
    
    def start_time_with_zone=(time_with_zone)
      zone_name = time_with_zone.time_zone.name
      localtime = time_with_zone.in_time_zone(zone_name)
      @timezone = Timezones::ZONES[zone_name]
      @start_time = localtime.strftime('%I:%M%p')
      @date = localtime.strftime('%Y-%m-%d')
    end

  end
end
