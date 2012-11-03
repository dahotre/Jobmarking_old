require 'net/http'
require 'trimmer'

class Job < ActiveRecord::Base
  include Trimmer
  include ActionView::Helpers::SanitizeHelper

  trimmed_fields :url, :title, :description
  validates_presence_of :url
  validates_format_of :url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix

  before_create :redirect_und_parse

  attr_accessor :diffHash, :newDesc

  def redirect_und_parse
    logger.info 'begin redirect_und_parse'
    begin
      response = let_redirect
      parsedUrl = Domainatrix.parse(self.acturl)
      logger.info 'got to ' + parsedUrl.domain
      UrlParser.parse parsedUrl.domain.downcase, response, self
    rescue ArgumentError => ae
      self.warn = 'This URL redirects indefinitely. Please verify.'
    rescue Exception => e
      self.warn = e.message
    end

  end

  def let_redirect
    fetch_resp = UrlParser.fetch self.url
    logger.info fetch_resp[:response].class
    if fetch_resp[:response].is_a? Net::HTTPSuccess
      logger.info 'response is a succes: ' + fetch_resp[:url]
      self.acturl = fetch_resp[:url]
      return fetch_resp[:response]
    else
      raise 'Problems finding the actual page for this URL.'
    end
  end

end
