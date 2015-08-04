require 'active_model'
require 'active_support/core_ext/time/zones'
require 'active_support/core_ext/time/calculations'

module Braincert
  # Possible values for the "recurring course" setting
  REPEAT_DAILY, REPEAT_MON_THRU_SAT, REPEAT_MON_THRU_FRI,
  REPEAT_WEEKLY, REPEAT_MONTHLY = *(1..5)

  class LiveClass
    require_relative 'timezones'

    include ActiveModel::Validations
    include ActiveModel::Serializers::JSON
    include ActiveModel::Conversion

    include Braincert::Request
    
    # Public attributes auto-assigned by API after creation
    attr_accessor :id, :user_id
    
    # Public required attributes on creation
    attr_accessor :title
    validates_presence_of :title

    # +timezone+ must be a timezone code.  We provide a convenience
    # method to convert Rails/IANA timezone names to these codes.
    attr_accessor :timezone
    validates_inclusion_of :timezone, :in => Braincert::Timezones::ZONE_CODES.keys

    # +start_time+, +end_time+, and +date+ must be provided in very
    # specific formats for the API.  We provide convenience methods
    # to set these up.
    attr_accessor :start_time, :end_time
    validates_format_of :start_time, :with => /\A\d\d:\d\d[AP]M\Z/
    validates_format_of :end_time, :with => /\A\d\d:\d\d[AP]M\Z/

    # a class doesn't have to repeat, but if it is repeating, then
    # we need a repeat type and number of classes.
    validates_numericality_of :end_classes_count, :in => (1..30), :if => :recurring?
    validates_numericality_of :repeat, :in => (1..5), :if => :recurring?

    attr_accessor :date
    validates_format_of :date, :with => /\A\d\d\d\d-\d\d-\d\d\Z/


    # Optional attributes on creation
    attr_accessor :currency, :ispaid, :is_recurring, :repeat, :end_classes_count, :end_date, :seat_attendees, :record, :format


    # attributes that are returned by GETs but don't seem to be specified at creation
    attr_accessor :duration     # in seconds
    attr_accessor :privacy      # 0=public
    attr_accessor :label        # ???
    
    attr_reader :errors         # like ActiveRecord::Errors object
    
    # attributes returned by certain API calls that we don't model at all
    UNUSED_API_ATTRIBUTES = %w(status description published label privacy)

    # default values for optional attributes on create
    DEFAULT_ATTRIBUTES = {
      :ispaid => 0,             # not paid (from Braincert point of view)
      :currency => 'USD',
      :is_recurring => 0,
      :repeat => Braincert::REPEAT_WEEKLY,
      :end_classes_count => 1,
      :seat_attendees => 25,
      :record => 1,             # 0=don't record
      :format => 'json',
      :privacy => 1
    }

    def initialize(attrs = {})
      DEFAULT_ATTRIBUTES.merge(attrs).each_pair { |k,v| self.send("#{k}=", v) }
      @persisted = false
      @errors = ActiveModel::Errors.new(self)
    end

    def recurring? ; is_recurring.to_i > 0 ; end

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

    # API wrapper methods

    # Save a created course. Freezes the local copy since the API does not support modifying.
    def save
      errors.add(:connection, "Existing classes cannot be updated") and return nil if @persisted
      return nil unless valid?
      if (json = self.do_request('schedule', self.attributes))
        @id = json['class_id']
        @persisted = true
        self.freeze
      else
        nil
      end
    end

    def find(id)
      if (json = self.do_request('getclass', :class_id => id))
        klass = Braincert::LiveClass.new.from_json
        debugger
      end
    end

    def all
      if (json = self.do_request('listclass'))
        # success means we have an array of hashes.  Each one has "id" key which is class ID,
        # but also has some attributes that aren't modeled on our side: 
      end
    end

    # convert attributes retrieved from API call to attributes suitable for calling constructor

    def self.from_attributes(a)
      # recover the zone info
      a['start_time_with_zone'] = recover_time_with_zone(*(a.values_at('date', 'start_time', 'timezone')))
      # some keys we don't model at all
      a.delete('end_time')      # will be computed from duration and given a zone
      # string keys that must be turned into integers
      %w(duration repeat seat_attendees end_classes_count ispaid record id).each { |k| a[k] = a[k].to_i }
      UNUSED_API_ATTRIBUTES.each { |att| a.delete att }
      a
    end

    def self.recover_time_with_zone(date, time, zone_code)
      temp = Time.zone        # save current zone
      Time.zone = Braincert::Timezones::ZONE_CODES[zone_code]
      local_time = Time.zone.parse "#{date} #{time}"
      Time.zone = temp
      local_time
    end
  
    # serialize to JSON for creation

    def attributes
      attrs = {
        'title' => title,
        'timezone' => timezone,      
        'start_time' => start_time,    
        'end_time' => end_time,
        'date' => date,
        'seat_attendees' => seat_attendees,
        'record' => record,
        'format' => 'json'
      }
      if is_recurring > 0
        attrs['is_recurring'] = 1
        attrs['repeat'] = repeat
        attrs['end_classes_count'] = end_classes_count
      end
      if ispaid > 0
        attrs['currency'] = currency
        attrs['ispaid'] =  1
      end
      attrs
    end

    private

    def set_end_time_from_duration
      if (@duration.to_i > 0 && @localtime)
        @end_time = (@localtime + @duration).strftime('%I:%M%p')
      end
    end
  end
end
