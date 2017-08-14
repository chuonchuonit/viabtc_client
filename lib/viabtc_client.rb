require "viabtc_client/version"

require 'rest-client'
require 'openssl'
require 'addressable/uri'

module ViabtcClient
  class << self
    attr_accessor :configuration
  end

  def self.setup
    @configuration ||= Configuration.new
    yield( configuration )
  end

  class Configuration
    attr_accessor :key, :secret

    def intialize
      @key    = ''
      @secret = ''
    end
  end

  def self.ticker code
    get 'market/ticker', market: code
  end

  def self.depth code, merge=0, limit=100
    get 'market/depth', {market: code, merge: merge, limit: limit}
  end

  def self.deals code
    get 'market/deals', market: code
  end

  def self.kline code
    get 'market/kline', market: code
  end

  def self.balances
    get_balance
  end

  protected

  def self.resource
    @@resouce ||= RestClient::Resource.new( 'https://www.viabtc.com/api/v1/' )
  end

  def self.get_balance
    params = {}
    params[:access_id] = configuration.key
    resource[ "balance?access_id=#{configuration.key}" ].get authorization: create_sign(params)
  end

  def self.get( command, params = {} )
    resource[ command ].get params: params
  end

  def self.post( command, params = {} )
    params[:nonce]   = Time.now.to_i * 1000
    params[:key] = configuration.key
    params[:signature] = create_sign( params )
    resource[ command ].post params
  end

  def self.create_sign( data )
    data[:secret_key] = configuration.secret
    encoded_data = Addressable::URI.form_encode( data )

    md5 = Digest::MD5.new
    md5.update encoded_data
    sc = md5.hexdigest
    sc.upcase
  end

end
