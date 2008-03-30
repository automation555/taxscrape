require 'rubygems'
require 'mechanize'

module Tax
  class State
   
    attr_accessor :state, :city, :county, :rate, :package

    def initialize(state,city=:all,specified_options={})
      default_options = {}
      options = default_options.merge specified_options
      specified_options.keys.each do |key|
        default_options.keys.include?(key) || raise(Chronic::InvalidArgumentException, "#{key} is not a valid option key.")
      end
      @state = state
      @city = city
      @package = []
      case state
      when :colorado
        uri = "https://www.taxview.state.co.us/QueryTaxrates.aspx?"
      end
      doc = Req.new(uri).response
      parse(doc)
      p @package
    end

    private

    def parse(doc)
      case @state
      when :colorado
        form = doc.form('_ctl0')
        form.fields.name('ListCity').options[1..-1].each do |it|
          begin #this needs debugging
          p it.select
          p @city = it.text #to be sure
          resp = Req.new(form, :submit).response
          data = resp.at('#lblCity')
          @rate = data.inner_text.match(/rate is(.*)/)[1].to_f
          #place = data.inner_text.split('.').last.split('is in')
          #city = place.first.strip
          #county = place.last.strip
          #TODO. some results belone to two states etc.
          @package << [@state.to_s.upcase, city, county, @rate] if city && @rate
          rescue;puts 'woops';end
        end
      end
    end
  end

  class Req

    attr_accessor :request, :response

    def initialize(req,method=:get)
      agent = WWW::Mechanize.new
      @requst = req
      case method
      when :get
        @response = agent.get(req)
      when :submit
        @response = agent.submit(req, req.buttons.first)
      end
    end
  end
end
