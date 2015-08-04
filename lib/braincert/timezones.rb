module Braincert
  class Timezones
    # keys are Rails TimeZone names; values are the integers used to
    #    refer to that time zone in BrainCert API.  List is from
    #  https://www.braincert.com/developer/virtualclassroom-api

    ZONES = {}
    ZONE_CODES = {}
    
    private

    def self.timezone_list()
      %q[
      28=>(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London
      30=>(GMT) Monrovia, Reykjavik
      72=>(GMT+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna
      53=>(GMT+01:00) Brussels, Copenhagen, Madrid, Paris
      14=>(GMT+01:00) Sarajevo, Skopje, Warsaw, Zagreb
      71=>(GMT+01:00) West Central Africa
      83=>(GMT+02:00) Amman
      84=>(GMT+02:00) Beirut
      24=>(GMT+02:00) Cairo
      61=>(GMT+02:00) Harare, Pretoria
      27=>(GMT+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius
      35=>(GMT+02:00) Jerusalem
      21=>(GMT+02:00) Minsk
      86=>(GMT+02:00) Windhoek
      31=>(GMT+03:00) Athens, Istanbul, Minsk
      2=>(GMT+03:00) Baghdad
      49=>(GMT+03:00) Kuwait, Riyadh
      54=>(GMT+03:00) Moscow, St. Petersburg, Volgograd
      19=>(GMT+03:00) Nairobi
      87=>(GMT+03:00) Tbilisi
      34=>(GMT+03:30) Tehran
      1=>(GMT+04:00) Abu Dhabi, Muscat
      88=>(GMT+04:00) Baku
      9=>(GMT+04:00) Baku, Tbilisi, Yerevan
      89=>(GMT+04:00) Port Louis
      47=>(GMT+04:30) Kabul
      25=>(GMT+05:00) Ekaterinburg
      90=>(GMT+05:00) Islamabad, Karachi
      73=>(GMT+05:00) Islamabad, Karachi, Tashkent
      33=>(GMT+05:30) Chennai, Kolkata, Mumbai, New Delhi
      62=>(GMT+05:30) Sri Jayawardenepura
      91=>(GMT+05:45) Kathmandu
      42=>(GMT+06:00) Almaty, Novosibirsk
      12=>(GMT+06:00) Astana, Dhaka
      41=>(GMT+06:30) Rangoon
      59=>(GMT+07:00) Bangkok, Hanoi, Jakarta
      50=>(GMT+07:00) Krasnoyarsk
      17=>(GMT+08:00) Beijing, Chongqing, Hong Kong, Urumqi
      46=>(GMT+08:00) Irkutsk, Ulaan Bataar
      60=>(GMT+08:00) Kuala Lumpur, Singapore
      70=>(GMT+08:00) Perth
      63=>(GMT+08:00) Taipei
      65=>(GMT+09:00) Osaka, Sapporo, Tokyo
      77=>(GMT+09:00) Seoul
      75=>(GMT+09:00) Yakutsk
      10=>(GMT+09:30) Adelaide
      4=>(GMT+09:30) Darwin
      20=>(GMT+10:00) Brisbane
      5=>(GMT+10:00) Canberra, Melbourne, Sydney
      74=>(GMT+10:00) Guam, Port Moresby
      64=>(GMT+10:00) Hobart
      69=>(GMT+10:00) Vladivostok
      15=>(GMT+11:00) Magadan, Solomon Is., New Caledonia
      44=>(GMT+12:00) Auckland, Wellington
      26=>(GMT+12:00) Fiji, Kamchatka, Marshall Is.
      6=>(GMT-01:00) Azores
      8=>(GMT-01:00) Cape Verde Is.
      39=>(GMT-02:00) Mid-Atlantic
      22=>(GMT-03:00) Brasilia
      94=>(GMT-03:00) Buenos Aires
      55=>(GMT-03:00) Buenos Aires, Georgetown
      29=>(GMT-03:00) Greenland
      95=>(GMT-03:00) Montevideo
      45=>(GMT-03:30) Newfoundland
      3=>(GMT-04:00) Atlantic Time (Canada)
      57=>(GMT-04:00) Georgetown, La Paz, San Juan
      96=>(GMT-04:00) Manaus
      51=>(GMT-04:00) Santiago
      76=>(GMT-04:30) Caracas
      56=>(GMT-05:00) Bogota, Lima, Quito
      23=>(GMT-05:00) Eastern Time (US & Canada)
      67=>(GMT-05:00) Indiana (East)
      11=>(GMT-06:00) Central America
      16=>(GMT-06:00) Central Time (US & Canada)
      37=>(GMT-06:00) Guadalajara, Mexico City, Monterrey
      7=>(GMT-06:00) Saskatchewan
      68=>(GMT-07:00) Arizona
      38=>(GMT-07:00) Chihuahua, La Paz, Mazatlan
      40=>(GMT-07:00) Mountain Time (US & Canada)
      52=>(GMT-08:00) Pacific Time (US & Canada)
      104=>(GMT-08:00) Tijuana, Baja California
      48=>(GMT-09:00) Alaska
      32=>(GMT-10:00) Hawaii
      58=>(GMT-11:00) Midway Island, Samoa
      18=>(GMT-12:00) International Date Line West
      105=>(GMT-4:00) Eastern Daylight Time (US & Canada)
      13=>(GMT+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague
]
    end
    
    # We maintain two mappings. The first maps an IANA timezone name (eg "Midway Island") to
    # Braincert's zone code, eg "Midway Island" => "58".
    # The second maps their zone code to _one_ IANA name, eg "58" => "Midway Island".  The second
    # mapping loses information, but we have no choice because once a class has been created, Braincert
    # only preserves the zone code and a *nonstandard* name for the zone, so the only way to recover
    # the zone info is by mapping the zone code to *some* standard IANA name.  Yuck.
    
    self.timezone_list.split(/\n/).each do |entry|
      next unless entry =~ /\s*(\d+)=>\(\S+\)\s+(.*)/
      code = $1
      $2.split(/,\s*/).each do |place|
        ZONES[place] = code
        ZONE_CODES[code] ||= place
      end
    end

  end
end
