require 'net/http'
require 'trimmer'

class Job < ActiveRecord::Base
  include Trimmer
  include ActionView::Helpers::SanitizeHelper

  trimmed_fields :url, :title, :description
  validates_presence_of :url
  validates_format_of :url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix

  before_create :redirectAndParse

  attr_accessor :diffHash, :newDesc
  attr_accessible :url

  def redirectAndParse
    logger.debug 'begin redirectAndParse'
    begin
      urlParser = UrlParser.new
      responseAndUrlHash = urlParser.getResponse self.url
      self.acturl = responseAndUrlHash[:url]
      response = responseAndUrlHash[:response]

      domainName = Domainatrix.parse(self.acturl).domain
      logger.debug 'Domain is ' + domain

      parsedDetails = urlParser.parseHtmlToFindDetails(domain.downcase, response)
      self.title = parsedDetails[:title]
      self.description = parsedDetails[:description]
      self.location = parsedDetails[:location]

    rescue ArgumentError => ae
      self.warn = 'This URL redirects indefinitely. Please verify.'
    rescue Exception => e
      self.warn = e.message
    end

  end

end
