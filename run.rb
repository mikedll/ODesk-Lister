
require 'rubygems'
require 'bundler'
Bundler.require


require 'active_support/all'


def webservice_jobs( params )
  response = RestClient.get 'https://www.odesk.com/api/profiles/v1/search/jobs.xml', :params => params

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


showjobs
