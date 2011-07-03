
require 'rubygems'
require 'bundler'
Bundler.require

require 'active_support/all'
require 'digest/md5'

API_KEY = ENV['ODESK_API_KEY']
API_SECRET = ENV['ODESK_API_SECRET']
ODESK_ROOT = 'https://www.odesk.com/'


def params_signed( params )
  raise "Need a key and secret, but couldn't find them in environment." if API_KEY.blank? or API_SECRET.blank?

  params.merge!(:api_key => API_KEY)
  params.merge!(:api_sig => 
                Digest::MD5.hexdigest(API_SECRET.to_s + params.sort { |a,b| a.first <=> b.first }.flatten.join.to_s))
end

def hours
  query = "SELECT week_worked_on, hours, earnings, charges, agency_id WHERE provider_id = AND week_worked_on = '2011-06-27'"
  provider_id = "~~b7c77f857ebb0450"
  params = params_signed(:tq => query, :tqx => 'out:json')
  RestClient.get "#{ODESK_ROOT}/gds/timereports/v1/providers/#{provider_id}/hours.xml", :params => params
  doc = Nokogiri::XML( response )
  puts doc
  []
end

def webservice_jobs( params )
  response = RestClient.get '#{ODESK_ROOT}/api/profiles/v1/search/jobs.xml', :params => params

  doc = Nokogiri::XML( response )
  jobs = doc.css('jobs job').map do |job|
    res = {}
    
    {:id => 'ciphertext',
      :duration => 'op_est_duration',
      :title => 'op_title', 
      :minpay => 'op_pref_hourly_rate_min',
      :maxpay => 'op_pref_hourly_rate_max', 
      :hours => 'hours_per_week',
      :posted_at =>'date_posted'}.each do |k,v|
      res[k] = job.at_css(v).content
    end
    res
  end
end

def getjobs(q, c1)
  day = 2.days.ago.strftime('%m-%d-%Y')
  result_max = 50
  pagesize = 20

  jobs = []
  (result_max / pagesize.to_f).ceil.times do |i|

    params = { :t => 'Hourly', 
      :q => q,
      :c1 => c1,
      :dp => day,
      :page =>  '#{i}:#{pagesize}'
    }

    jobs += webservice_jobs( params )
  end
  jobs
end

def showjobs
  jobs = [["C++", 'Software Development'],
          ["Python", 'Software Development'],
          ["Ruby", 'Web Development']].map { |q,c1| getjobs(q,c1) }.flatten.shuffle
  
  puts "Showing #{jobs.size} jobs"
  jobs.each do |job|
    job.each do |k,v|
      if k == :id
        puts "#{k}: https://www.odesk.com/jobs/#{v}"
      else
        puts "#{k}: #{v}\n"
      end
    end
    print "\n"
  end
end


# showjobs

hours

