require 'ipaddr'
require 'faraday/resolve_dns'
require 'spec_helper'

describe Faraday::ResolveDns do
  let(:rip) { described_class.new(lambda{|env| env}, {}) }

  context "resolvable" do
    before :each do
      # Socket returns a bunch of other stuff with gethostbyname. ipv6 addresses,
      # other socket information, whatever. We ignore it all internally and return
      # only valid ipv4 addresses, so just append what we're checking to some
      # garbage data like we expect.
      return_addresses = ['garbage', [], 30]
      return_addresses += [IPAddr.new('169.254.169.254').hton]
      expect(Socket).to receive(:gethostbyname).and_return(return_addresses)
    end

    it "rewrites hostname" do
      url = URI.parse("http://test.com/ipn/endpoint")
      env = { url: url }
      new_env = rip.call(env)
      expect(new_env[:url].to_s).to eq("http://169.254.169.254/ipn/endpoint")
      expect(new_env[:request_headers]['Host']).to eq("test.com:80")
    end

    it "preserves custom port" do
      url = URI.parse("http://test.com:1999/ipn/endpoint")
      env = { url: url }
      new_env = rip.call(env)
      expect(new_env[:url].to_s).to eq("http://169.254.169.254:1999/ipn/endpoint")
      expect(new_env[:request_headers]['Host']).to eq("test.com:1999")
    end

    it "has empty host header for IP address hostname" do
      url = URI.parse("http://169.254.169.254:1999/ipn/endpoint")
      env = { url: url }
      new_env = rip.call(env)
      expect(new_env[:url].to_s).to eq("http://169.254.169.254:1999/ipn/endpoint")
      expect(new_env[:request_headers]['Host']).to eq("")
    end
  end

  context "unresolvable" do
    before :each do
      expect(Socket).to receive(:gethostbyname).and_return([])
    end

    it "throws error if hostname is unresolvable" do
      url = URI.parse("http://nonexistant.com/ipn/endpoint")
      env = { url: url }
      expect{rip.call(env)}.to raise_error(Faraday::ResolveDns::DNSError)
    end
  end
end
