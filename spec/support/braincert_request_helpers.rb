
module BraincertRequestHelpers 
  STUB_SITE = 'http://example.com'
  Braincert.site = STUB_SITE
  def regexp_for(action)
    Regexp.new "\\A#{STUB_SITE}/#{action}\\?"
  end
  def fixture(file)
    {:status => 200, :body => IO.read("spec/fixtures/#{file}.json")}
  end
end

