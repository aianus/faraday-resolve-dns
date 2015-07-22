require 'ipaddr'

module Faraday
  class ResolveDns < Faraday::Middleware
    class DNSError < Faraday::Error::ClientError ; end

    def initialize(app, options = {})
      super(app)
    end

    def call(env)
      host = env[:url].hostname
      port = env[:url].port
#      puts "LALALA: #{Socket.gethostbyname(host)}"
#      puts "HERPADERP: #{addresses(host)}"
      resolved_address = addresses(host).first
      raise DNSError.new "Could not resolve hostname '#{env[:url].host}'" if !resolved_address
      env[:url].hostname = resolved_address.to_string
      env[:request_headers] ||= {}
      env[:request_headers]['Host'] =
        if (IPAddr.new(host) rescue nil)
          ''
        else
          "#{host}:#{port}"
        end
      @app.call(env)
    end

    def addresses(hostname)
      Socket.gethostbyname(hostname).map { |a| IPAddr.new_ntoh(a) rescue nil }.compact
    end
  end
  Request.register_middleware resolve_dns: lambda { ResolveDns }
end