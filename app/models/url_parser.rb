require 'nokogiri'
require 'domainatrix'
require 'sanitize'
require 'net/https'

class UrlParser

  def fetch(uri_str, limit = 10)
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
        return {:response => response, :url => uri_str}
    end
  end

  def parseHtmlToFindDetails(domain, response)
    Rails.logger.info 'Start a fetchin'
    lookups = Lookup.find_all_by_domain_and_deleted(domain, false)
    lookupToUse = Lookup.new

    lookupToUse.title = '//*[@itemprop="title"]'
    lookupToUse.description = '//*[@itemprop="description"]'
    lookupToUse.location = '//*[@itemprop="jobLocation"]'
    lookupToUse.domain = domain

    unless lookups.blank?
      Rails.logger.debug 'found lookup'
      lookupToUse = lookups.first
    end

    parsedDetailsHash = findDetailsWithLookup(response, lookupToUse)

    if parsedDetailsHash[:title].blank? or parsedDetailsHash[:description].blank? or parsedDetailsHash[:location].blank?

      if parsedDetailsHash[:title].blank?
        lookupToUse.title = nil
      end
      if parsedDetailsHash[:description].blank?
        lookupToUse.description = nil
      end
      if parsedDetailsHash[:location].blank?
        lookupToUse.location = nil
      end

      topLookups = Lookup.all(:limit => 5, :order => 'otherDomainHits DESC')

      topLookups.each do |topLookup|
        newDetails = findDetailsWithLookup(response, topLookup)
        if parsedDetailsHash[:title].blank?
          parsedDetailsHash[:title] = newDetails[:title] unless newDetails[:title].blank?
          lookupToUse.title = topLookup.title
        end
        if parsedDetailsHash[:description].blank?
          parsedDetailsHash[:description] = newDetails[:description] unless newDetails[:description].blank?
          lookupToUse.description = topLookup.description
        end
        if parsedDetailsHash[:location].blank?
          parsedDetailsHash[:location] = newDetails[:location] unless newDetails[:location].blank?
          lookupToUse.location = topLookup.location
        end

        if (!parsedDetailsHash[:title].blank? and !parsedDetailsHash[:description].blank? and
            !parsedDetailsHash[:location].blank?)
          Lookup.where(:domain => domain, :title => lookupToUse.title , :description => lookupToUse.description,
                       :location => lookupToUse.location).first_or_create(:deleted => false, :otherDomainHits => 0)
          break
        end
      end

    else
      Lookup.where(:domain => domain).first_or_create(:title => lookupToUse.title,
                                                      :description => lookupToUse.description,
                                                      :location => lookupToUse.location, :otherDomainHits => 0,
                                                      :deleted => false)
    end

    return parsedDetailsHash
  end

  def findDetailsWithLookup(response, lookup)
    if (response.is_a? Net::HTTPSuccess or response.is_a? Net::HTTPRedirection)
      doc = Nokogiri::HTML(response.entity)
      if !doc.blank?
        doc.xpath('//script').remove
        doc.xpath('//style').remove

        title = Sanitize.clean(doc.xpath(lookup.title).to_s).gsub(/\s+/, " ")
        description = Sanitize.clean(doc.xpath(lookup.description).to_s).gsub(/\s+/, " ")
        location = Sanitize.clean(doc.xpath(lookup.location).to_s).gsub(/\s+/, " ")

        return {:title => title, :description => description, :location => location}

      else
        Rails.logger.error 'failed to parse' + self.url
      end
    else
      raise 'Could not reach URL..'
    end
  end


  def getResponse(url)
    responseAndUrlHash = fetch url
    logger.debug responseAndUrlHash[:response].class
    unless responseAndUrlHash[:response].is_a? Net::HTTPSuccess
      Rails.logger.error 'Response after redirect is still NOT a success..'
      raise 'Problems finding the actual page for this URL.'
    end
    return responseAndUrlHash
  end

end
