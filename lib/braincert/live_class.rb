require 'active_model'
require 'active_support/core_ext/time/zones'
require 'active_support/core_ext/time/calculations'

module Braincert
  class LiveClass
    require_relative 'timezones'

    include ActiveModel::Validations
    include ActiveModel::Serializers::JSON
    include ActiveModel::Conversion
    
    # Public attributes auto-assigned by API after creation
    attr_reader :class_id, :user_id, :published
    
    # Public required attributes on creation
    attr_accessor :title
    validates_presence_of :title

    # +timezone+ must be a timezone code.  We provide a convenience
    # method to convert Rails/IANA timezone names to these codes.
    attr_accessor :timezone
    validates_inclusion_of :timezone, :in => Braincert::Timezones::ZONE_CODES

    # +start_time+, +end_time+, and +date+ must be provided in very
    # specific formats for the API.  We provide convenience methods
    # to set these up.
    attr_accessor :start_time, :end_time
    validates_format_of :start_time, :with => /\A\d\d:\d\d[AP]M\Z/
    validates_format_of :end_time, :with => /\A\d\d:\d\d[AP]M\Z/

    attr_accessor :date
    validates_format_of :date, :with => /\A\d\d\d\d-\d\d-\d\d\Z/


    # Optional attributes on creation
    attr_accessor :currency, :ispaid, :is_recurring, :repeat, :end_classes_count, :end_date, :seat_attendees, :record, :format

    # Possible values for the "recurring course" setting
    REPEAT_DAILY, REPEAT_MON_THRU_SAT, REPEAT_MON_THRU_FRI, REPEAT_WEEKLY, REPEAT_MONTHLY = *(1..5)

    # attributes that are returned by GETs but don't seem to be specified at creation
    attr_accessor :duration     # in seconds
    attr_accessor :privacy      # 0=public
    attr_accessor :label        # ???
    

    # default values for optional attributes on create
    DEFAULT_ATTRIBUTES = {
      :ispaid => 0,             # not paid (from Braincert point of view)
      :currency => 'USD',
      :is_recurring => 0,
      :repeat => REPEAT_WEEKLY,
      :end_classes_count => 1,
      :seat_attendees => 25,
      :record => 1,             # 0=don't record
      :format => 'json',
      :privacy => 1
    }

    def initialize(attrs = {})
      DEFAULT_ATTRIBUTES.merge(attrs).each_pair { |k,v| self.send("#{k}=", v) }
      @persisted = false
    end

    def start_time_with_zone=(time_with_zone)
      zone_name = time_with_zone.time_zone.name
      @localtime = time_with_zone.in_time_zone(zone_name)
      @timezone = Timezones::ZONES[zone_name]
      @start_time = @localtime.strftime('%I:%M%p')
      @date = @localtime.strftime('%Y-%m-%d')
      set_end_time_from_duration
    end

    def duration=(duration)
      @duration = duration
      set_end_time_from_duration
    end

    # CRUD methods

    def save!
      resp = Braincert::Request.request('schedule', self.to_json)
    end
      

    # serialize to JSON for creation
    def attributes
      attrs = {
        'title' => nil,
        'timezone' => nil,      
        'start_time' => nil,    
        'end_time' => nil,      'end_classes_count' => nil,
        'date' => nil,          'seat_attendees' => 0,
        'record' => 0,
        'format' => 'json'
      }
      attrs['is_recurring'] = nil if is_recurring > 0
      attrs['currency'] = attrs['ispaid'] = nil if ispaid > 0
      attrs
    end
    

    private

    def set_end_time_from_duration
      if (@duration.to_i > 0 && @start_time)
        @end_time = (@localtime + @duration).strftime('%I:%M%p')
      end
    end
  end
end
