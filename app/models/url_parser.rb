require 'nokogiri'
require 'domainatrix'
require 'sanitize'
require 'net/https'

class UrlParser

  def self.fetch(uri_str, limit = 10)
    Rails.logger.info 'fetching ' + uri_str
    # You should choose a better exception.
    raise ArgumentError, 'too many HTTP redirects' if limit == 0
    uri = URI(uri_str)
    conn = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri, {"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.89 Safari/537.1"})
    
    response = conn.request(request)
  
    case response
    when Net::HTTPRedirection then
      location = response['location']
      Rails.logger.error "redirected to " + response['location']
      fetch(location, limit - 1)
    else
      Rails.logger.info 'success in redirection'
      return { :response => response, :url => uri_str}
    end
  end
  
  def self.parse(domain, response, job)
    Rails.logger.info 'Start a fetchin'
    begin
      lookups = Lookup.find_all_by_domain_and_deleted(domain, false)

        Rails.logger.info 'found lookup'
        if ( response.is_a? Net::HTTPSuccess or response.is_a? Net::HTTPRedirection )
          doc = Nokogiri::HTML(response.entity)
          if !doc.blank?
            doc.xpath('//script').remove
            doc.xpath('//style').remove
            title_xpath = '//*[@itemprop="title"]'
            description_xpath = '//*[@itemprop="description"]'
            location_xpath = '//h1[@itemprop="jobLocation"]'
            unless lookups.blank?
              title_xpath = lookups.first.title
              description_xpath = lookups.first.description
              location_xpath = lookups.first.location
            end
            job.title = Sanitize.clean(doc.xpath(title_xpath).to_s).gsub(/\s+/, " ")
            job.description = Sanitize.clean(doc.xpath(description_xpath).to_s).gsub(/\s+/, " ")
            job.location = Sanitize.clean(doc.xpath(location_xpath).to_s).gsub(/\s+/, " ")
            if job.title.blank? or job.description.blank?
              Rails.logger.error 'Could not scrape title/description'
              Rails.logger.error 'Here are the xpaths: ' + title_xpath + ' || ' + description_xpath
              Rails.logger.error 'Here is the document : ' + doc
            end
          else
            Rails.logger.error 'failed to parse' + self.url
          end
        else
          raise 'Could not reach URL..'
        end

    rescue SocketError => socketError
      Rails.logger.error 'Socket error.. Invalid URL provided..'
    rescue => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace      
    end
  end
    
end
