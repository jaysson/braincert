# Braincert

Gem that wraps a subset of the [Braincert Virtual Classroom API](https://www.braincert.com/developer/virtualclassroom-api)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'braincert', :git => 'git://github.com/armandofox/braincert.git'
```

And then execute:

    $ bundle

## Usage

BrainCert calls a live meeting a "class" or "live class", and a
recurring series of classes a "course".

This gem maps their notion of a "class" (including possible repetition)
to a Ruby object called `Braincert::LiveClass`.

## Get info about classes

```
Braincert.api_key = 'xxx'
# Get list of all classes we own.  Each includes an id attribute.
classes = Braincert::LiveClass.all
# Or get details about a particular course by id:
one_class = Braincert::LiveClass.find(classes.first.id)
# Returns nil and populates one_class.errors (ActiveModel errors object) 
# if failure
```

Because the API doesn't support updating a class in place (you have to
delete it and create a new class), `Braincert::LiveClass` objects are
frozen.

## Get "launch URL" for a class

The launch URL is the one that opens a browser window allowing people to
attend the class.  

## Create (schedule) a new class

Just as with ActiveModel, you create a new object, set its attributes,
and then save it.  The attributes can be set individually or passed as a
hash to the constructor.  Required attributes are shown here, see docs
for optional attributes.

```
new_class = Braincert::LiveClass.new
new_class.title = 'New Test Class'
new_class.start_time_with_zone = Time.zone.parse("Aug 05, 5:00pm")
# must be ActiveSupport::TimeWithZone instance (ie, responds to :time_zone)
new_class.duration = 3600        # in seconds
new_class.seat_attendees = 25    # max attendees including teacher
# optional for recurring classes:
new_class.repeat = Braincert::REPEAT_WEEKLY  # see doc for other values
new_class.end_classes_count = 3  # 3rd meeting is the final one
# nonrecurring classes (default)
new_class.repeat = nil

new_class.valid?        # runs validations as usual
new_class.save          # if result is nil, check new_class.errors
new_class.save!         # like save but raise Braincert::LiveClass::SaveError if fail
new_class.id            # => after save, will be non-nil (numeric)
new_class.persisted?    # => true after successful save
new_class.duration = 7200  # => raises exception, since object is now frozen
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/braincert/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

